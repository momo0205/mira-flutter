import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mira_flutter/config/api_config.dart';
import 'package:mira_flutter/main.dart';

Widget createTestApp(ApiConfig apiConfig) {
  return MiraApp(apiConfig: apiConfig);
}

void main() {
  testWidgets('shows settings screen when not configured', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final apiConfig = ApiConfig();
    await apiConfig.load();

    await tester.pumpWidget(createTestApp(apiConfig));
    await tester.pumpAndSettle();

    // Should show SettingsScreen with "服务器设置" title
    expect(find.text('服务器设置'), findsOneWidget);
  });

  testWidgets('shows service list when configured', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'server_url': 'https://api.example.com'});
    final apiConfig = ApiConfig();
    await apiConfig.load();

    await tester.pumpWidget(createTestApp(apiConfig));
    await tester.pumpAndSettle();

    // Should show ServiceListScreen with "Mira 投研终端" title
    expect(find.text('Mira 投研终端'), findsOneWidget);
  });
}
