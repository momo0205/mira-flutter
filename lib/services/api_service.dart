import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/service.dart';
import '../models/report.dart';

class ApiService {
  final ApiConfig _config;
  final Dio dio;

  ApiService(this._config, {Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
            ));

  Future<List<Service>> fetchServices() async {
    final response = await dio.get(_config.serviceUrl('/api/services'));
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Service.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Report>> fetchReports(String serviceId) async {
    final response = await dio.get(
      _config.serviceUrl('/api/services/$serviceId/reports'),
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Report.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> fetchReportContent(String serviceId, String reportId) async {
    final response = await dio.get(
      _config.serviceUrl('/api/services/$serviceId/reports/$reportId'),
    );
    return response.data as String;
  }
}
