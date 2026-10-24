import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mira_flutter/config/api_config.dart';
import 'package:mira_flutter/stores/favorite_store.dart';
import 'package:mira_flutter/stores/recent_store.dart';
import 'package:mira_flutter/main.dart';

Widget createTestApp(ApiConfig apiConfig, FavoriteStore favoriteStore, RecentStore recentStore) {
  return MiraApp(apiConfig: apiConfig, favoriteStore: favoriteStore, recentStore: recentStore);
}

void main() {
  testWidgets('shows settings screen when not configured',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final apiConfig = ApiConfig();
    await apiConfig.load();
    await apiConfig.save('');
    final favoriteStore = FavoriteStore();
    await favoriteStore.load();
    final recentStore = RecentStore();
    await recentStore.load();

    await tester.pumpWidget(createTestApp(apiConfig, favoriteStore, recentStore));
    await tester.pumpAndSettle();

    expect(find.text('服务器设置'), findsOneWidget);
  });
}
