import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mira_flutter/stores/favorite_store.dart';

void main() {
  group('FavoriteStore', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is empty', () async {
      final store = FavoriteStore();
      await store.load();
      expect(store.favorites, isEmpty);
    });

    test('toggle adds and removes favorite', () async {
      final store = FavoriteStore();
      await store.load();
      expect(store.isFavorite('report-1'), isFalse);
      await store.toggle('report-1', 'svc-1', 'Test Report');
      expect(store.isFavorite('report-1'), isTrue);
      final entry = store.favorites['report-1'];
      expect(entry!.serviceId, 'svc-1');
      expect(entry.title, 'Test Report');
      await store.toggle('report-1', 'svc-1', 'Test Report');
      expect(store.isFavorite('report-1'), isFalse);
    });

    test('toggle notifies listeners', () async {
      final store = FavoriteStore();
      await store.load();
      var notified = false;
      store.addListener(() => notified = true);
      await store.toggle('r1', 'svc', 'Title');
      expect(notified, isTrue);
    });
  });
}
