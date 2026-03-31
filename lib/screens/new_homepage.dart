import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/report_model.dart';
import '../models/result.dart';
import '../services/report_parser.dart';
import '../widgets/markdown_content_renderer.dart';

/// 新首页屏幕，加载并展示报告内容
class NewHomepage extends StatefulWidget {
  const NewHomepage({super.key});

  @override
  State<NewHomepage> createState() => _NewHomepageState();
}

class _NewHomepageState extends State<NewHomepage> {
  bool _loading = true;
  String? _error;
  ReportModel? _report;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final jsonString = await rootBundle.loadString('lib/models/data.json');
      final result = ReportParser.parseReport(jsonString);

      if (!mounted) return;

      switch (result) {
        case Success(:final data):
          setState(() {
            _report = data;
            _loading = false;
          });
        case Failure(:final message):
          setState(() {
            _error = message;
            _loading = false;
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadReport,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    final report = _report!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            report.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          ...report.sections.map((section) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MarkdownContentRenderer(markdownText: section.summary),
              )),
        ],
      ),
    );
  }
}
