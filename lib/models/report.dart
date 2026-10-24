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
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['date'] as String? ?? '');
    } catch (_) {
      parsedDate = DateTime(2000);
    }

    return Report(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      date: parsedDate,
      tags: (json['tags'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [],
      summary: json['summary'] as String?,
    );
  }
}
