import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../services/api_service.dart';

class ServiceStore extends ChangeNotifier {
  final ApiService _api;
  List<Service> _services = [];
  bool _loading = false;
  String? _error;

  ServiceStore(this._api);

  List<Service> get services => _services;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetchServices() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _services = await _api.fetchServices();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
