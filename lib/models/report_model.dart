class ContentSection {
  final String contentType;
  final String summary;

  const ContentSection({
    required this.contentType,
    required this.summary,
  });

  Map<String, dynamic> toJson() => {
        'contentType': contentType,
        'summary': summary,
      };

  factory ContentSection.fromJson(Map<String, dynamic> json) {
    return ContentSection(
      contentType: json['contentType'] as String,
      summary: json['summary'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSection &&
          runtimeType == other.runtimeType &&
          contentType == other.contentType &&
          summary == other.summary;

  @override
  int get hashCode => contentType.hashCode ^ summary.hashCode;
}

class ReportModel {
  final String title;
  final String shareUrl;
  final List<ContentSection> sections;

  const ReportModel({
    required this.title,
    required this.shareUrl,
    required this.sections,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'shareUrl': shareUrl,
        'sections': sections.map((s) => s.toJson()).toList(),
      };

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      title: json['title'] as String,
      shareUrl: json['shareUrl'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => ContentSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportModel &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          shareUrl == other.shareUrl &&
          _listEquals(sections, other.sections);

  @override
  int get hashCode => title.hashCode ^ shareUrl.hashCode ^ sections.hashCode;

  static bool _listEquals(List<ContentSection> a, List<ContentSection> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
