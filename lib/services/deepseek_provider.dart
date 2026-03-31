import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:http/http.dart' as http;

/// Custom LlmProvider implementation for DeepSeek API.
///
/// Communicates with the DeepSeek chat completions endpoint using
/// SSE (Server-Sent Events) for streaming responses.
class DeepSeekProvider extends LlmProvider with ChangeNotifier {
  DeepSeekProvider({
    String? apiKey,
    this.model = 'deepseek-chat',
    this.systemPrompt,
  }) : _apiKey = 'sk-d48eb49fa0e24a25993f13b07cc1f7ef' { //apiKey ?? const String.fromEnvironment('DEEPSEEK_API_KEY') {
    assert(_apiKey.trim().isNotEmpty, 'DEEPSEEK_API_KEY 未配置，请通过 --dart-define 传入');
  }

  static const _baseUrl = 'https://api.deepseek.com/chat/completions';

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
    final messages = <Map<String, String>>[
      if (systemPrompt != null) {'role': 'system', 'content': systemPrompt!},
      {'role': 'user', 'content': prompt},
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

    final messages = <Map<String, String>>[
      if (systemPrompt != null) {'role': 'system', 'content': systemPrompt!},
      ..._history.map(
        (m) => {
          'role': m.origin.isUser ? 'user' : 'assistant',
          'content': m.text ?? '',
        },
      ),
    ];

    final buffer = StringBuffer();
    yield* _requestStream(messages).map((chunk) {
      llmMessage.append(chunk);
      buffer.write(chunk);
      return chunk;
    });

    notifyListeners();
  }

  /// Builds the JSON request body for the DeepSeek API.
  Map<String, dynamic> _buildRequestBody(List<Map<String, String>> messages) {
    return {
      'model': model,
      'messages': messages,
      'stream': true,
    };
  }

  /// Parses a single SSE data line and extracts the delta content.
  /// Returns `null` for non-content lines (empty, [DONE], malformed JSON).
  String? _parseSseLine(String line) {
    if (!line.startsWith('data: ')) return null;
    final data = line.substring(6).trim();
    if (data == '[DONE]' || data.isEmpty) return null;
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;
      final delta = (choices[0] as Map<String, dynamic>)['delta']
          as Map<String, dynamic>?;
      return delta?['content'] as String?;
    } catch (_) {
      return null;
    }
  }

  /// Sends an HTTP POST request with SSE streaming to the DeepSeek API.
  Stream<String> _requestStream(List<Map<String, String>> messages) async* {
    try {
      final request = http.Request('POST', Uri.parse(_baseUrl))
        ..headers.addAll({
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode(_buildRequestBody(messages));

      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        yield '请求失败，状态码: ${response.statusCode}';
        return;
      }

      yield* response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .map(_parseSseLine)
          .where((content) => content != null)
          .cast<String>();
    } on Exception catch (_) {
      yield '网络连接失败，请检查网络设置';
    }
  }
}
