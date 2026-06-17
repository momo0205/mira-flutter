import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/api_config.dart';
import 'services/api_service.dart';
import 'stores/service_store.dart';
import 'stores/report_store.dart';
import 'stores/favorite_store.dart';
import 'stores/cache_store.dart';
import 'screens/service_list_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final apiConfig = ApiConfig();
  await apiConfig.load();
  runApp(MiraApp(apiConfig: apiConfig));
}

class MiraApp extends StatelessWidget {
  final ApiConfig apiConfig;

  const MiraApp({super.key, required this.apiConfig});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(apiConfig);
    final cacheStore = CacheStore();
    final favoriteStore = FavoriteStore();
    favoriteStore.load();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: apiConfig),
        Provider.value(value: apiService),
        ChangeNotifierProvider(create: (_) => ServiceStore(apiService)),
        ChangeNotifierProvider(create: (_) => ReportStore(apiService, cacheStore)),
        ChangeNotifierProvider.value(value: favoriteStore),
      ],
      child: MaterialApp(
        title: 'Mira 投研终端',
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
