import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteStore extends ChangeNotifier {
  static const _key = 'favorites';
  Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = (prefs.getStringList(_key) ?? []).toSet();
    notifyListeners();
  }

  bool isFavorite(String reportId) => _favorites.contains(reportId);

  Future<void> toggle(String reportId) async {
    if (_favorites.contains(reportId)) {
      _favorites.remove(reportId);
    } else {
      _favorites.add(reportId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _favorites.toList());
    notifyListeners();
  }
}
