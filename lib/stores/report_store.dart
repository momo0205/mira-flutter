import 'package:flutter/foundation.dart';
import '../models/report.dart';
import '../services/api_service.dart';
import 'cache_store.dart';

class ReportStore extends ChangeNotifier {
  final ApiService _api;
  final CacheStore _cache;
  List<Report> _reports = [];
  bool _loading = false;
  String? _error;

  ReportStore(this._api, this._cache);

  List<Report> get reports => _reports;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchReports(String serviceId) async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _reports = await _api.fetchReports(serviceId);
      _reports.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> prefetchContents(String serviceId) async {
    for (final report in _reports.take(3)) {
      final isCached = await _cache.isCached(serviceId, report.id);
      if (isCached) continue;
      try {
        final content = await _api.fetchReportContent(serviceId, report.id);
        await _cache.put(serviceId, report.id, content);
      } catch (_) {}
    }
  }

  Future<String> fetchContent(String serviceId, String reportId) async {
    try {
      final cached = await _cache.get(serviceId, reportId);
      if (cached != null) return cached;
      final content = await _api.fetchReportContent(serviceId, reportId);
      await _cache.put(serviceId, reportId, content);
      return content;
    } catch (e) {
      rethrow;
    }
  }

  List<Report> search(String query) {
    if (query.isEmpty) return _reports;
    final q = query.toLowerCase();
    return _reports.where((r) {
      return r.title.toLowerCase().contains(q) ||
          r.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }
}
