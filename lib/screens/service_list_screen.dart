import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../stores/service_store.dart';
import '../stores/favorite_store.dart';
import '../stores/recent_store.dart';
import '../widgets/service_card.dart';
import '../widgets/empty_state.dart';
import 'settings_screen.dart';
import 'report_list_screen.dart';
import 'report_read_screen.dart';
import '../models/report.dart';
import '../models/service.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceStore>().fetchServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IRON'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索服务...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
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
            onPressed: () => _showFavorites(context),
          ),
          IconButton(
            icon: const Icon(Icons.manage_search),
            onPressed: () => _showGlobalSearch(context),
          ),
        ],
      ),
      body: _query.isEmpty ? _buildWithRecent() : _buildFilteredServices(),
    );
  }

  Widget _buildWithRecent() {
    return Consumer2<ServiceStore, RecentStore>(
      builder: (context, store, recentStore, _) {
        if (store.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (store.error != null) {
          return EmptyState(
            icon: Icons.cloud_off,
            message: store.error!,
            actionLabel: '重试',
            onAction: () => store.fetchServices(),
          );
        }
        return RefreshIndicator(
          onRefresh: () => store.fetchServices(),
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            children: [
              if (recentStore.entries.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 16, 4),
                  child: Text('最近浏览',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline)),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: recentStore.entries.length.clamp(0, 10),
                    itemBuilder: (_, i) {
                      final entry = recentStore.entries[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportReadScreen(
                                  serviceId: entry.serviceId,
                                  serviceName: entry.serviceName,
                                  report: Report(
                                    id: entry.reportId,
                                    title: entry.title,
                                    date: DateTime.now(),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: SizedBox(
                            width: 160,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium),
                                  const Spacer(),
                                  Text(entry.serviceName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(indent: 16, endIndent: 16),
              ],
              if (store.services.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(icon: Icons.inbox, message: '暂无可用服务'),
                )
              else
                ...store.services.map((s) => ServiceCard(
                      service: s,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportListScreen(
                              serviceId: s.id,
                              serviceName: s.name,
                            ),
                          ),
                        );
                      },
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilteredServices() {
    return Consumer<ServiceStore>(
      builder: (context, store, _) {
        if (store.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (store.error != null) {
          return EmptyState(
            icon: Icons.cloud_off,
            message: store.error!,
            actionLabel: '重试',
            onAction: () => store.fetchServices(),
          );
        }
        final services = _filtered(store.services);
        if (services.isEmpty) {
          return EmptyState(
            icon: Icons.search_off,
            message: '未找到匹配 "$_query" 的服务',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: services.length,
          itemBuilder: (_, i) => ServiceCard(
            service: services[i],
            onTap: () {
              final service = services[i];
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
        );
      },
    );
  }

  List<Service> _filtered(List<Service> services) {
    if (_query.isEmpty) return services;
    final q = _query.toLowerCase();
    return services.where((s) {
      return s.name.toLowerCase().contains(q) ||
          (s.description?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void _showFavorites(BuildContext context) {
    final favorites = context.read<FavoriteStore>().favorites;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: favorites.isEmpty
            ? const SizedBox(
                height: 200,
                child:
                    EmptyState(icon: Icons.star_border, message: '还没有收藏的报告'),
              )
            : ListView(
                children: favorites.values
                    .map((entry) => ListTile(
                          title: Text(entry.title),
                          subtitle: Text(
                            '来自: ${entry.serviceId}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          leading:
                              const Icon(Icons.star, color: Colors.amber),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReportReadScreen(
                                  serviceId: entry.serviceId,
                                  serviceName: entry.serviceId,
                                  report: Report(
                                    id: entry.reportId,
                                    title: entry.title,
                                    date: DateTime.now(),
                                  ),
                                ),
                              ),
                            );
                          },
                        ))
                    .toList(),
              ),
      ),
    );
  }

  void _showGlobalSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _GlobalSearchDelegate(
        apiService: context.read<ApiService>(),
        serviceStore: context.read<ServiceStore>(),
      ),
    );
  }
}

class _GlobalSearchDelegate extends SearchDelegate<String> {
  final ApiService apiService;
  final ServiceStore serviceStore;

  _GlobalSearchDelegate({required this.apiService, required this.serviceStore});

  @override
  String get searchFieldLabel => '搜索报告（标题/标签）...';

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('输入股票代码或关键词搜索'));
    }
    return _buildResultsWidget(context);
  }

  @override
  Widget buildResults(BuildContext context) => _buildResultsWidget(context);

  Widget _buildResultsWidget(BuildContext context) {
    final services = serviceStore.services;
    if (services.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<_SearchHit>>(
      future: _search(services, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final hits = snapshot.data ?? [];
        if (hits.isEmpty) {
          return const Center(child: Text('未找到匹配的报告'));
        }
        return ListView.builder(
          itemCount: hits.length,
          itemBuilder: (_, i) {
            final hit = hits[i];
            return ListTile(
              title: Text(hit.report.title),
              subtitle: Text('${hit.serviceName} — ${hit.report.tags.join(", ")}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                close(context, '');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportReadScreen(
                      serviceId: hit.serviceId,
                      serviceName: hit.serviceName,
                      report: hit.report,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<_SearchHit>> _search(
      List<Service> services, String query) async {
    final q = query.toLowerCase();
    final hits = <_SearchHit>[];
    for (final svc in services) {
      try {
        final reports = await apiService.fetchReports(svc.id);
        for (final r in reports) {
          if (r.title.toLowerCase().contains(q) ||
              r.tags.any((t) => t.toLowerCase().contains(q))) {
            hits.add(_SearchHit(
              serviceId: svc.id,
              serviceName: svc.name,
              report: r,
            ));
          }
        }
      } catch (_) {}
    }
    return hits;
  }
}

class _SearchHit {
  final String serviceId;
  final String serviceName;
  final Report report;
  const _SearchHit(
      {required this.serviceId,
      required this.serviceName,
      required this.report});
}
