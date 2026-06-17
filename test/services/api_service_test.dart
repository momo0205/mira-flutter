import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mira_flutter/config/api_config.dart';
import 'package:mira_flutter/services/api_service.dart';

class FakeAdapter implements HttpClientAdapter {
  final List<dynamic> Function(String path, String method) handler;

  FakeAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final data = handler(options.uri.path, options.method);
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

class StringAdapter implements HttpClientAdapter {
  final String content;

  StringAdapter(this.content);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      content,
      200,
      headers: {Headers.contentTypeHeader: ['text/markdown']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiConfig config;
  late ApiService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    config = ApiConfig();
    await config.save('http://localhost:8080');
  });

  test('fetchServices returns list of Service', () async {
    service = ApiService(config);
    service.dio.httpClientAdapter = FakeAdapter((path, method) {
      expect(path, '/api/services');
      expect(method, 'GET');
      return [
        {'id': 'mira', 'name': 'Mira 投研', 'report_count': 3},
        {'id': 'briefing', 'name': '市场简报'},
      ];
    });

    final services = await service.fetchServices();
    expect(services.length, 2);
    expect(services[0].id, 'mira');
    expect(services[0].name, 'Mira 投研');
    expect(services[1].reportCount, 0);
  });

  test('fetchReports returns list of Report', () async {
    service = ApiService(config);
    service.dio.httpClientAdapter = FakeAdapter((path, method) {
      return [
        {'id': 'r1', 'title': '测试', 'date': '2026-06-16'},
      ];
    });

    final reports = await service.fetchReports('mira');
    expect(reports.length, 1);
    expect(reports[0].title, '测试');
  });

  test('fetchReportContent returns markdown string', () async {
    service = ApiService(config);
    final mdContent = '# 测试报告\n\n正文内容';
    service.dio.httpClientAdapter = StringAdapter(mdContent);

    final content = await service.fetchReportContent('mira', 'r1');
    expect(content, mdContent);
  });
}
