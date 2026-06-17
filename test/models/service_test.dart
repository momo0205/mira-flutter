import 'package:flutter_test/flutter_test.dart';
import 'package:mira_flutter/models/service.dart';
import 'package:mira_flutter/models/report.dart';

void main() {
  group('Service', () {
    test('fromJson creates Service with all fields', () {
      final json = {
        'id': 'mira',
        'name': 'Mira 投研',
        'description': '股票投研分析',
        'report_count': 5,
      };
      final service = Service.fromJson(json);
      expect(service.id, 'mira');
      expect(service.name, 'Mira 投研');
      expect(service.description, '股票投研分析');
      expect(service.reportCount, 5);
    });

    test('fromJson handles missing report_count and description', () {
      final json = {
        'id': 'mira',
        'name': 'Mira 投研',
      };
      final service = Service.fromJson(json);
      expect(service.reportCount, 0);
      expect(service.description, isNull);
    });
  });

  group('Report', () {
    test('fromJson creates Report with all fields', () {
      final json = {
        'id': '600519-standard',
        'title': '贵州茅台 标准分析',
        'date': '2026-06-16',
        'tags': ['白酒', '消费'],
        'summary': '茅台2026Q1分析',
      };
      final report = Report.fromJson(json);
      expect(report.id, '600519-standard');
      expect(report.title, '贵州茅台 标准分析');
      expect(report.date, DateTime(2026, 6, 16));
      expect(report.tags, ['白酒', '消费']);
      expect(report.summary, '茅台2026Q1分析');
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'report-1',
        'title': '测试报告',
        'date': '2026-06-16',
      };
      final report = Report.fromJson(json);
      expect(report.tags, isEmpty);
      expect(report.summary, isNull);
    });
  });
}
