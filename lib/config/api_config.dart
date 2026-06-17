import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig extends ChangeNotifier {
  static const _key = 'server_url';
  String _serverUrl = '';

  String get serverUrl => _serverUrl;
  bool get isConfigured => _serverUrl.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _serverUrl = prefs.getString(_key) ?? '';
    notifyListeners();
  }

  Future<void> save(String url) async {
    _serverUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _serverUrl);
    notifyListeners();
  }

  String serviceUrl(String path) => '$_serverUrl$path';
}
