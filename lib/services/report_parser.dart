import 'dart:convert';

import '../models/report_model.dart';
import '../models/result.dart';

/// 解析 data.json 的嵌套 JSON 结构为 ReportModel
class ReportParser {
  /// 从 JSON 字符串解析报告数据
  static Result<ReportModel> parseReport(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return parseReportFromMap(json);
    } on FormatException {
      return const Failure('Invalid JSON format');
    } catch (e) {
      return Failure('Unexpected error: $e');
    }
  }

  /// 从 JSON Map 解析报告数据
  static Result<ReportModel> parseReportFromMap(Map<String, dynamic> json) {
    try {
      // Navigate to data.data
      final outerData = json['data'];
      if (outerData is! Map<String, dynamic>) {
        return const Failure('Missing path: data');
      }
      final innerData = outerData['data'];
      if (innerData is! Map<String, dynamic>) {
        return const Failure('Missing path: data.data');
      }

      // Extract title from data.data.shareDTO.extra.title
      final shareDTO = innerData['shareDTO'];
      if (shareDTO is! Map<String, dynamic>) {
        return const Failure('Missing path: data.data.shareDTO');
      }
      final extra = shareDTO['extra'];
      if (extra is! Map<String, dynamic>) {
        return const Failure('Missing path: data.data.shareDTO.extra');
      }
      final title = extra['title'];
      if (title is! String) {
        return const Failure('Missing report title');
      }

      // Extract shareUrl from data.data.shareDTO.shareUrl
      final shareUrl = shareDTO['shareUrl'];
      if (shareUrl is! String) {
        return const Failure('Missing path: data.data.shareDTO.shareUrl');
      }

      // Extract content from data.data.msgHistoryRoundVersionDTO.rounds[0].messages[0].content[0].data
      final msgHistory = innerData['msgHistoryRoundVersionDTO'];
      if (msgHistory is! Map<String, dynamic>) {
        return const Failure(
            'Missing path: data.data.msgHistoryRoundVersionDTO');
      }
      final rounds = msgHistory['rounds'];
      if (rounds is! List || rounds.isEmpty) {
        return const Failure('No content rounds found');
      }
      final firstRound = rounds[0];
      if (firstRound is! Map<String, dynamic>) {
        return const Failure('Invalid round format');
      }
      final messages = firstRound['messages'];
      if (messages is! List || messages.isEmpty) {
        return const Failure('No messages found');
      }
      final firstMessage = messages[0];
      if (firstMessage is! Map<String, dynamic>) {
        return const Failure('Invalid message format');
      }
      final content = firstMessage['content'];
      if (content is! List || content.isEmpty) {
        return const Failure('No content data found');
      }
      final firstContent = content[0];
      if (firstContent is! Map<String, dynamic>) {
        return const Failure('Invalid content format');
      }
      final dataArray = firstContent['data'];
      if (dataArray is! List) {
        return const Failure('No content data found');
      }

      // Filter contentType == "summary" and parse to ContentSection
      final sections = <ContentSection>[];
      for (final item in dataArray) {
        if (item is Map<String, dynamic> &&
            item['contentType'] == 'summary') {
          final itemData = item['data'];
          if (itemData is Map<String, dynamic>) {
            sections.add(ContentSection(
              contentType: item['contentType'] as String,
              summary: (itemData['summary'] as String?) ?? '',
            ));
          }
        }
      }

      return Success(ReportModel(
        title: title,
        shareUrl: shareUrl,
        sections: sections,
      ));
    } catch (e) {
      return Failure('Parse error: $e');
    }
  }
}
