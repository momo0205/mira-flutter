class Service {
  final String id;
  final String name;
  final String? description;
  final int reportCount;

  const Service({
    required this.id,
    required this.name,
    this.description,
    this.reportCount = 0,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      reportCount: (json['report_count'] as num?)?.toInt() ?? 0,
    );
  }
}
