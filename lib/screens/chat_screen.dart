import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';

import '../services/openrouter_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final OpenRouterProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = OpenRouterProvider(
      apiKey: 'YOUR_OPENROUTER_API_KEY',
    );
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('AI 助手')),
        body: LlmChatView(
          provider: _provider,
          enableVoiceNotes: true,
        ),
      ),
    );
  }
}
