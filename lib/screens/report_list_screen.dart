import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../stores/report_store.dart';
import '../stores/favorite_store.dart';
import '../widgets/report_card.dart';
import '../widgets/empty_state.dart';
import 'report_read_screen.dart';

class ReportListScreen extends StatefulWidget {
  final String serviceId;
  final String serviceName;

  const ReportListScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportStore>().fetchReports(widget.serviceId);
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
        title: Text(widget.serviceName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索报告...',
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
      ),
      body: Consumer<ReportStore>(
        builder: (context, store, _) {
          if (store.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (store.error != null) {
            return EmptyState(
              icon: Icons.error_outline,
              message: '加载失败',
              actionLabel: '重试',
              onAction: () => store.fetchReports(widget.serviceId),
            );
          }
          final reports = store.search(_query);
          if (reports.isEmpty) {
            return _query.isNotEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    message: '未找到匹配 "$_query" 的报告',
                  )
                : const EmptyState(icon: Icons.inbox, message: '暂无报告');
          }
          return RefreshIndicator(
            onRefresh: () => store.fetchReports(widget.serviceId),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              itemCount: reports.length,
              itemBuilder: (_, i) {
                final report = reports[i];
                final isFavorite = context.watch<FavoriteStore>().isFavorite(report.title);
                return ReportCard(
                  report: report,
                  isFavorite: isFavorite,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportReadScreen(
                          serviceId: widget.serviceId,
                          report: report,
                        ),
                      ),
                    );
                  },
                  onToggleFavorite: () => context.read<FavoriteStore>().toggle(report.title),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
