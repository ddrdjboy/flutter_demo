import '../models/product_table_item.dart';

/// 渲染段基类
sealed class RenderSegment {
  const RenderSegment();
}

/// 普通 Markdown 文本段
class MarkdownSegment extends RenderSegment {
  final String markdown;
  const MarkdownSegment(this.markdown);
}

/// 产品表格段
class ProductTableSegment extends RenderSegment {
  final List<ProductTableItem> products;
  const ProductTableSegment(this.products);
}

/// 从 Markdown 文本中分离普通内容和产品表格
class ContentSectionParser {
  // Matches a markdown table that has the product columns header
  static final _tableHeaderPattern = RegExp(
    r'^\|\s*Product Title\s*\|',
    caseSensitive: false,
  );

  /// 将 Markdown 文本拆分为渲染段（普通 Markdown 或产品表格）
  static List<RenderSegment> parse(String markdown) {
    final lines = markdown.split('\n');
    final segments = <RenderSegment>[];
    final buffer = StringBuffer();

    var i = 0;
    while (i < lines.length) {
      if (_tableHeaderPattern.hasMatch(lines[i])) {
        // Flush any buffered markdown
        _flushBuffer(buffer, segments);

        // Collect the full table (header + separator + data rows)
        final tableLines = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('|')) {
          tableLines.add(lines[i]);
          i++;
        }

        final products = parseProductTable(tableLines.join('\n'));
        if (products.isNotEmpty) {
          segments.add(ProductTableSegment(products));
        }
      } else {
        buffer.writeln(lines[i]);
        i++;
      }
    }

    _flushBuffer(buffer, segments);
    return segments;
  }

  /// 解析 Markdown 表格文本为 ProductTableItem 列表
  static List<ProductTableItem> parseProductTable(String tableMarkdown) {
    final lines = tableMarkdown
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.length < 3) return []; // Need header + separator + at least 1 row

    // Parse header to find column indices
    final headers = _parseCells(lines[0]);
    final titleIdx = _findColumn(headers, 'Product Title');
    final imageIdx = _findColumn(headers, 'Image');
    final priceIdx = _findColumn(headers, 'Price');
    final salesIdx = _findColumn(headers, 'Sales Volume');
    final sourceIdx = _findColumn(headers, 'Source');

    if (titleIdx == -1 || priceIdx == -1) return [];

    // Skip header (0) and separator (1), parse data rows
    final products = <ProductTableItem>[];
    for (var i = 2; i < lines.length; i++) {
      final cells = _parseCells(lines[i]);
      if (cells.isEmpty) continue;

      final rawTitle = _getCell(cells, titleIdx);
      final titleLink = _extractLink(rawTitle);
      final rawImage = _getCell(cells, imageIdx);
      final imageUrl = _extractImageUrl(rawImage);

      products.add(ProductTableItem(
        title: titleLink?.text ?? rawTitle,
        titleUrl: titleLink?.url,
        imageUrl: imageUrl,
        price: _getCell(cells, priceIdx),
        salesVolume: _getCell(cells, salesIdx),
        source: _getCell(cells, sourceIdx),
      ));
    }

    return products;
  }

  static void _flushBuffer(StringBuffer buffer, List<RenderSegment> segments) {
    final text = buffer.toString().trimRight();
    if (text.isNotEmpty) {
      segments.add(MarkdownSegment(text));
    }
    buffer.clear();
  }

  /// Split a markdown table row into cells
  static List<String> _parseCells(String row) {
    final trimmed = row.trim();
    if (!trimmed.startsWith('|')) return [];
    // Remove leading/trailing pipes and split
    final inner =
        trimmed.substring(1, trimmed.endsWith('|') ? trimmed.length - 1 : trimmed.length);
    return inner.split('|').map((c) => c.trim()).toList();
  }

  /// Find column index by header name (case-insensitive, partial match)
  static int _findColumn(List<String> headers, String name) {
    final lower = name.toLowerCase();
    for (var i = 0; i < headers.length; i++) {
      if (headers[i].toLowerCase().contains(lower)) return i;
    }
    return -1;
  }

  static String _getCell(List<String> cells, int index) {
    if (index < 0 || index >= cells.length) return '';
    return cells[index];
  }

  /// Extract [text](url) from markdown link
  static _LinkResult? _extractLink(String text) {
    final match = RegExp(r'\[([^\]]*)\]\(([^)]*)\)').firstMatch(text);
    if (match == null) return null;
    return _LinkResult(text: match.group(1) ?? '', url: match.group(2) ?? '');
  }

  /// Extract image URL from ![alt](url)
  static String? _extractImageUrl(String text) {
    final match = RegExp(r'!\[[^\]]*\]\(([^)]*)\)').firstMatch(text);
    return match?.group(1);
  }
}

class _LinkResult {
  final String text;
  final String url;
  const _LinkResult({required this.text, required this.url});
}
