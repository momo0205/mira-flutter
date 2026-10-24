import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/api_config.dart';
import 'services/api_service.dart';
import 'stores/service_store.dart';
import 'stores/report_store.dart';
import 'stores/favorite_store.dart';
import 'stores/recent_store.dart';
import 'stores/cache_store.dart';
import 'screens/service_list_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiConfig = ApiConfig();
  final favoriteStore = FavoriteStore();
  final recentStore = RecentStore();
  await Future.wait([apiConfig.load(), favoriteStore.load(), recentStore.load()]);
  runApp(MiraApp(
    apiConfig: apiConfig,
    favoriteStore: favoriteStore,
    recentStore: recentStore,
  ));
}

class MiraApp extends StatelessWidget {
  final ApiConfig apiConfig;
  final FavoriteStore favoriteStore;
  final RecentStore recentStore;

  const MiraApp({
    super.key,
    required this.apiConfig,
    required this.favoriteStore,
    required this.recentStore,
  });

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(apiConfig);
    final cacheStore = CacheStore();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: apiConfig),
        Provider.value(value: apiService),
        ChangeNotifierProvider(create: (_) => ServiceStore(apiService)),
        ChangeNotifierProvider(create: (_) => ReportStore(apiService, cacheStore)),
        ChangeNotifierProvider.value(value: favoriteStore),
        ChangeNotifierProvider.value(value: recentStore),
      ],
      child: MaterialApp(
        title: 'IRON',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFF58A6FF),
          useMaterial3: true,
        ),
        home: Consumer<ApiConfig>(
          builder: (context, config, _) {
            if (!config.isConfigured) {
              return const SettingsScreen();
            }
            return const ServiceListScreen();
          },
        ),
      ),
    );
  }
}
