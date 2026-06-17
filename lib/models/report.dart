class Report {
  final String id;
  final String title;
  final DateTime date;
  final List<String> tags;
  final String? summary;

  const Report({
    required this.id,
    required this.title,
    required this.date,
    this.tags = const [],
    this.summary,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      summary: json['summary'] as String?,
    );
  }
}
