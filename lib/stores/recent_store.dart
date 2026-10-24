import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentEntry {
  final String reportId;
  final String serviceId;
  final String serviceName;
  final String title;
  final int viewedAt;

  const RecentEntry({
    required this.reportId,
    required this.serviceId,
    required this.serviceName,
    required this.title,
    required this.viewedAt,
  });

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'title': title,
        'viewedAt': viewedAt,
      };

  factory RecentEntry.fromJson(Map<String, dynamic> json) => RecentEntry(
        reportId: json['reportId'] as String,
        serviceId: json['serviceId'] as String,
        serviceName: json['serviceName'] as String,
        title: json['title'] as String,
        viewedAt: json['viewedAt'] as int,
      );
}

class RecentStore extends ChangeNotifier {
  static const _key = 'recent_reports';
  static const _maxItems = 20;
  List<RecentEntry> _entries = [];

  List<RecentEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _entries = list
            .map((e) => RecentEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        _entries.sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
      } catch (_) {
        _entries = [];
      }
    }
  }

  Future<void> add({
    required String reportId,
    required String serviceId,
    required String serviceName,
    required String title,
  }) async {
    _entries.removeWhere((e) => e.reportId == reportId);
    _entries.insert(
      0,
      RecentEntry(
        reportId: reportId,
        serviceId: serviceId,
        serviceName: serviceName,
        title: title,
        viewedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (_entries.length > _maxItems) {
      _entries = _entries.take(_maxItems).toList();
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _entries.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }
}
