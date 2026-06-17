import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/service_store.dart';
import '../stores/favorite_store.dart';
import '../widgets/service_card.dart';
import '../widgets/empty_state.dart';
import 'settings_screen.dart';
import 'report_list_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceStore>().fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mira 投研终端'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              _showFavorites(context);
            },
          ),
        ],
      ),
      body: Consumer<ServiceStore>(
        builder: (context, store, _) {
          if (store.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (store.error != null) {
            return EmptyState(
              icon: Icons.cloud_off,
              message: '无法连接服务器',
              actionLabel: '重试',
              onAction: () => store.fetchServices(),
            );
          }
          if (store.services.isEmpty) {
            return const EmptyState(icon: Icons.inbox, message: '暂无可用服务');
          }
          return RefreshIndicator(
            onRefresh: () => store.fetchServices(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: store.services.length,
              itemBuilder: (_, i) => ServiceCard(
                service: store.services[i],
                onTap: () {
                  final service = store.services[i];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportListScreen(
                        serviceId: service.id,
                        serviceName: service.name,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFavorites(BuildContext context) {
    final favorites = context.read<FavoriteStore>().favorites;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: favorites.isEmpty
            ? const SizedBox(
                height: 200,
                child: EmptyState(icon: Icons.star_border, message: '还没有收藏的报告'),
              )
            : ListView(
                children: favorites
                    .map((id) => ListTile(
                          title: Text(id),
                          leading: const Icon(Icons.star, color: Colors.amber),
                        ))
                    .toList(),
              ),
      ),
    );
  }
}
