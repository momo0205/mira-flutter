import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteEntry {
  final String reportId;
  final String serviceId;
  final String title;

  const FavoriteEntry({
    required this.reportId,
    required this.serviceId,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'serviceId': serviceId,
        'title': title,
      };

  factory FavoriteEntry.fromJson(Map<String, dynamic> json) => FavoriteEntry(
        reportId: json['reportId'] as String,
        serviceId: json['serviceId'] as String,
        title: json['title'] as String,
      );
}

class FavoriteStore extends ChangeNotifier {
  static const _key = 'favorites_v2';
  Map<String, FavoriteEntry> _favorites = {};

  Map<String, FavoriteEntry> get favorites => _favorites;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _favorites = {
          for (final e in list)
            (e as Map<String, dynamic>)['reportId'] as String:
                FavoriteEntry.fromJson(e)
        };
      } catch (_) {
        _favorites = {};
      }
    }
    notifyListeners();
  }

  bool isFavorite(String reportId) => _favorites.containsKey(reportId);

  Future<void> toggle(
      String reportId, String serviceId, String title) async {
    if (_favorites.containsKey(reportId)) {
      _favorites.remove(reportId);
    } else {
      _favorites[reportId] =
          FavoriteEntry(reportId: reportId, serviceId: serviceId, title: title);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final list =
        _favorites.values.map((e) => e.toJson()).toList();
    await prefs.setString(_key, jsonEncode(list));
  }
}
