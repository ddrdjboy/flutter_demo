import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 应用内 WebView 页面，以 modal 方式弹出展示外部链接
class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;

  const WebViewScreen({super.key, required this.url, this.title});

  /// 以 present（modal）方式打开 WebView
  static void open(BuildContext context, {required String url, String? title}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => WebViewScreen(url: url, title: title),
      ),
    );
  }

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.title ?? '';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) async {
          if (!mounted) return;
          final pageTitle = await _controller.getTitle();
          setState(() {
            _loading = false;
            if (widget.title == null && pageTitle != null && pageTitle.isNotEmpty) {
              _currentTitle = pageTitle;
            }
          });
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
