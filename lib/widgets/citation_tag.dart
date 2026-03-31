import 'package:flutter/material.dart';

import '../screens/webview_screen.dart';

/// 渲染引用来源标签，显示来源名称，点击后打开链接
class CitationTag extends StatelessWidget {
  final String sourceName;
  final String url;

  const CitationTag({
    super.key,
    required this.sourceName,
    required this.url,
  });

  void _openUrl(BuildContext context) {
    WebViewScreen.open(context, url: url, title: sourceName);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _openUrl(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          sourceName,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
