import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../screens/webview_screen.dart';
import '../services/content_section_parser.dart';
import 'citation_tag.dart';
import 'product_table.dart';

/// 渲染单个 ContentSection 的 Markdown 内容
/// 自动处理 <cite> 标签和产品表格的拦截
class MarkdownContentRenderer extends StatelessWidget {
  final String markdownText;

  const MarkdownContentRenderer({super.key, required this.markdownText});

  @override
  Widget build(BuildContext context) {
    final segments = ContentSectionParser.parse(markdownText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((segment) {
        return switch (segment) {
          MarkdownSegment(:final markdown) =>
            _MarkdownWithCitations(markdown: markdown),
          ProductTableSegment(:final products) =>
            ProductTable(products: products),
        };
      }).toList(),
    );
  }
}

/// Regex to match <cite>[name](url)</cite> patterns
final _citePattern = RegExp(r'<cite>\[([^\]]*)\]\(([^)]*)\)</cite>');

/// Splits markdown text by <cite> tags, rendering markdown segments
/// via flutter_markdown and cite tags as CitationTag widgets.
class _MarkdownWithCitations extends StatelessWidget {
  final String markdown;

  const _MarkdownWithCitations({required this.markdown});

  @override
  Widget build(BuildContext context) {
    final parts = _splitByCitations(markdown);

    if (parts.length == 1 && parts.first is _TextPart) {
      // No citations — render as plain markdown
      return _buildMarkdown(context, (parts.first as _TextPart).text);
    }

    // Mix of markdown and citation tags — use a Wrap for inline flow
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildMixedContent(context, parts),
    );
  }

  List<Widget> _buildMixedContent(
      BuildContext context, List<_Part> parts) {
    final widgets = <Widget>[];
    final textBuffer = StringBuffer();

    for (final part in parts) {
      if (part is _TextPart) {
        textBuffer.write(part.text);
      } else if (part is _CitePart) {
        // Flush any buffered text as markdown
        if (textBuffer.isNotEmpty) {
          widgets.add(_buildMarkdown(context, textBuffer.toString()));
          textBuffer.clear();
        }
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: CitationTag(sourceName: part.name, url: part.url),
          ),
        );
      }
    }

    // Flush remaining text
    if (textBuffer.isNotEmpty) {
      widgets.add(_buildMarkdown(context, textBuffer.toString()));
    }

    return widgets;
  }

  Widget _buildMarkdown(BuildContext context, String text) {
    final textTheme = Theme.of(context).textTheme;

    return MarkdownBody(
      data: text,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: textTheme.bodyLarge,
        h1: textTheme.headlineLarge,
        h2: textTheme.headlineMedium,
        h3: textTheme.headlineSmall,
        listBullet: textTheme.bodyLarge,
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          WebViewScreen.open(context, url: href, title: text);
        }
      },
    );
  }

  /// Split markdown text into text parts and citation parts
  static List<_Part> _splitByCitations(String text) {
    final parts = <_Part>[];
    var lastEnd = 0;

    for (final match in _citePattern.allMatches(text)) {
      if (match.start > lastEnd) {
        parts.add(_TextPart(text.substring(lastEnd, match.start)));
      }
      parts.add(_CitePart(
        name: match.group(1) ?? '',
        url: match.group(2) ?? '',
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      parts.add(_TextPart(text.substring(lastEnd)));
    }

    return parts;
  }
}

sealed class _Part {}

class _TextPart extends _Part {
  final String text;
  _TextPart(this.text);
}

class _CitePart extends _Part {
  final String name;
  final String url;
  _CitePart({required this.name, required this.url});
}
