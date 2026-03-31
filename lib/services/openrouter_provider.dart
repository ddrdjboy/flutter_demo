import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:http/http.dart' as http;

/// LlmProvider implementation for OpenRouter API with multimodal support.
class OpenRouterProvider extends LlmProvider with ChangeNotifier {
  OpenRouterProvider({
    String? apiKey,
    this.model = 'google/gemini-3-flash-preview',
    this.systemPrompt,
  }) : _apiKey = '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' {//apiKey ??
            //const String.fromEnvironment('OPENROUTER_API_KEY') {
    assert(_apiKey.trim().isNotEmpty, 'OPENROUTER_API_KEY 未配置');
  }

  static const _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  final String _apiKey;
  final String model;
  final String? systemPrompt;
  final List<ChatMessage> _history = [];

  @override
  Iterable<ChatMessage> get history => _history;

  @override
  set history(Iterable<ChatMessage> history) {
    _history
      ..clear()
      ..addAll(history);
    notifyListeners();
  }

  @override
  Stream<String> generateStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) {
    final content = _buildContent(prompt, attachments);
    final messages = <Map<String, dynamic>>[
      if (systemPrompt != null) {'role': 'system', 'content': systemPrompt!},
      {'role': 'user', 'content': content},
    ];
    return _requestStream(messages);
  }

  @override
  Stream<String> sendMessageStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) async* {
    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    _history.addAll([userMessage, llmMessage]);

    final messages = <Map<String, dynamic>>[
      if (systemPrompt != null) {'role': 'system', 'content': systemPrompt!},
      ..._history.map((m) => _chatMessageToApi(m)),
    ];

    yield* _requestStream(messages).map((chunk) {
      llmMessage.append(chunk);
      return chunk;
    });

    notifyListeners();
  }

  /// Converts a ChatMessage to the OpenAI-compatible API format,
  /// including image attachments as base64 data URLs.
  Map<String, dynamic> _chatMessageToApi(ChatMessage m) {
    final role = m.origin.isUser ? 'user' : 'assistant';
    final attachments = m.attachments;

    if (!m.origin.isUser || attachments.isEmpty) {
      return {'role': role, 'content': m.text ?? ''};
    }

    return {'role': role, 'content': _buildContent(m.text ?? '', attachments)};
  }

  /// Builds multimodal content array with text + image + audio parts.
  dynamic _buildContent(String text, Iterable<Attachment> attachments) {
    final imageAttachments = attachments.whereType<ImageFileAttachment>();
    final audioAttachments = attachments
        .whereType<FileAttachment>()
        .where((a) => a is! ImageFileAttachment && a.mimeType.startsWith('audio/'));

    if (imageAttachments.isEmpty && audioAttachments.isEmpty) return text;

    final parts = <Map<String, dynamic>>[
      {'type': 'text', 'text': text},
      for (final img in imageAttachments)
        {
          'type': 'image_url',
          'image_url': {
            'url': 'data:${img.mimeType};base64,${base64Encode(img.bytes)}',
          },
        },
      for (final audio in audioAttachments)
        {
          'type': 'input_audio',
          'input_audio': {
            'data': base64Encode(audio.bytes),
            'format': _audioFormat(audio.mimeType),
          },
        },
    ];
    return parts;
  }

  /// Extracts audio format string from mimeType (e.g. "audio/wav" -> "wav").
  String _audioFormat(String mimeType) {
    final sub = mimeType.split('/').last.toLowerCase();
    // Map common mime subtypes to OpenRouter-expected format names
    const mapping = {
      'mpeg': 'mp3',
      'x-m4a': 'm4a',
      'mp4': 'm4a',
      'x-wav': 'wav',
      'wave': 'wav',
      'ogg': 'ogg',
      'flac': 'flac',
      'aac': 'aac',
      'aiff': 'aiff',
    };
    return mapping[sub] ?? sub;
  }

  Stream<String> _requestStream(List<Map<String, dynamic>> messages) async* {
    try {
      final body = jsonEncode({
        'model': model,
        'messages': messages,
        'stream': true,
      });

      final request = http.Request('POST', Uri.parse(_baseUrl))
        ..headers.addAll({
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        })
        ..body = body;

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        yield '请求失败 (${response.statusCode}): $errorBody';
        return;
      }

      yield* response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map(_parseSseLine)
          .where((c) => c != null)
          .cast<String>();
    } on Exception catch (e) {
      yield '网络连接失败: $e';
    }
  }

  String? _parseSseLine(String line) {
    if (!line.startsWith('data: ')) return null;
    final data = line.substring(6).trim();
    if (data == '[DONE]' || data.isEmpty) return null;
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;
      final delta =
          (choices[0] as Map<String, dynamic>)['delta'] as Map<String, dynamic>?;
      return delta?['content'] as String?;
    } catch (_) {
      return null;
    }
  }
}
