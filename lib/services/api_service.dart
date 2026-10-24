import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/service.dart';
import '../models/report.dart';

class AppException implements Exception {
  final String message;
  final String? detail;
  const AppException(this.message, {this.detail});

  @override
  String toString() => message;
}

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
    try {
      final response = await dio.get(_config.serviceUrl('/api/services'));
      final list = response.data as List<dynamic>;
      return list
          .map((e) {
            if (e is! Map<String, dynamic>) return null;
            return Service.fromJson(e);
          })
          .whereType<Service>()
          .toList();
    } on DioException catch (e) {
      throw AppException(_friendlyError(e));
    }
  }

  Future<List<Report>> fetchReports(String serviceId) async {
    try {
      final response = await dio.get(
        _config.serviceUrl('/api/services/$serviceId/reports'),
      );
      final list = response.data as List<dynamic>;
      return list
          .map((e) {
            if (e is! Map<String, dynamic>) return null;
            return Report.fromJson(e);
          })
          .whereType<Report>()
          .toList();
    } on DioException catch (e) {
      throw AppException(_friendlyError(e));
    }
  }

  Future<String> fetchReportContent(String serviceId, String reportId) async {
    try {
      final response = await dio.get(
        _config.serviceUrl('/api/services/$serviceId/reports/$reportId'),
        options: Options(responseType: ResponseType.plain),
      );
      return response.data as String;
    } on DioException catch (e) {
      throw AppException(_friendlyError(e));
    }
  }

  Future<Map<String, dynamic>> triggerResearch({
    required String service,
    String ticker = '600519',
    String market = 'A 股',
    String depth = 'standard',
    String concept = '',
  }) async {
    try {
      final response = await dio.post(
        _config.serviceUrl('/api/trigger'),
        data: {
          'service': service,
          'ticker': ticker,
          'market': market,
          'depth': depth,
          'concept': concept,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException(_friendlyError(e));
    }
  }

  String _friendlyError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络';
      case DioExceptionType.sendTimeout:
        return '发送超时，请检查网络';
      case DioExceptionType.receiveTimeout:
        return '服务器响应超时';
      case DioExceptionType.connectionError:
        return '无法连接到服务器，请检查地址和网络';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 404) return '请求的资源不存在';
        if (code == 500) return '服务器内部错误';
        return '服务器错误 (${code ?? '未知'})';
      case DioExceptionType.cancel:
        return '请求已取消';
      default:
        return '网络错误';
    }
  }
}
