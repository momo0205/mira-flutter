import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../services/api_service.dart';
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
  bool _sortNewestFirst = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final store = context.read<ReportStore>();
      await store.fetchReports(widget.serviceId);
      store.prefetchContents(widget.serviceId);
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
        actions: [
          IconButton(
            icon: Icon(_sortNewestFirst
                ? Icons.arrow_downward
                : Icons.arrow_upward),
            tooltip: _sortNewestFirst ? '按时间降序' : '按时间升序',
            onPressed: () {
              setState(() => _sortNewestFirst = !_sortNewestFirst);
            },
          ),
        ],
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
              message: store.error!,
              actionLabel: '重试',
              onAction: () => store.fetchReports(widget.serviceId),
            );
          }
          final reports = _sorted(store.search(_query));
          if (reports.isEmpty) {
            return _query.isNotEmpty
                ? EmptyState(
                    icon: Icons.search_off,
                    message: '未找到匹配 "$_query" 的报告',
                  )
                : const EmptyState(icon: Icons.inbox, message: '暂无报告');
          }
          return RefreshIndicator(
            onRefresh: () async {
              await store.fetchReports(widget.serviceId);
              store.prefetchContents(widget.serviceId);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: reports.length,
              itemBuilder: (_, i) {
                final report = reports[i];
                final isFavorite =
                    context.watch<FavoriteStore>().isFavorite(report.id);
                return ReportCard(
                  report: report,
                  isFavorite: isFavorite,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportReadScreen(
                          serviceId: widget.serviceId,
                          serviceName: widget.serviceName,
                          report: report,
                        ),
                      ),
                    );
                  },
                  onToggleFavorite: () => context
                      .read<FavoriteStore>()
                      .toggle(report.id, widget.serviceId, report.title),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTriggerDialog(context),
        tooltip: '触发新研究',
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Report> _sorted(List<Report> reports) {
    final sorted = List<Report>.from(reports);
    sorted.sort((a, b) => _sortNewestFirst
        ? b.date.compareTo(a.date)
        : a.date.compareTo(b.date));
    return sorted;
  }

  void _showTriggerDialog(BuildContext context) {
    final tickerController = TextEditingController();
    final conceptController = TextEditingController();
    String depth = 'standard';
    String market = 'A 股';
    bool loading = false;

    final isResearch = widget.serviceId == 'research';
    final isBriefing = widget.serviceId == 'briefing';
    final isIndustry = widget.serviceId == 'industry';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isResearch ? '触发个股研究' : (isBriefing ? '触发市场简报' : '触发行业分析')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isResearch) ...[
                TextField(
                  controller: tickerController,
                  decoration: const InputDecoration(
                    labelText: '股票代码',
                    hintText: '600519',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !loading,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: depth,
                  decoration: const InputDecoration(
                    labelText: '研究深度',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'quick_map', child: Text('快速扫描 (quick_map)')),
                    DropdownMenuItem(value: 'standard', child: Text('标准研究 (standard)')),
                    DropdownMenuItem(value: 'deep_dive', child: Text('深度研究 (deep_dive)')),
                  ],
                  onChanged: loading ? null : (v) => setDialogState(() => depth = v!),
                ),
              ] else if (isBriefing) ...[
                DropdownButtonFormField<String>(
                  initialValue: market,
                  decoration: const InputDecoration(
                    labelText: '市场范围',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'A 股', child: Text('A 股')),
                    DropdownMenuItem(value: '沪深两市', child: Text('沪深两市')),
                    DropdownMenuItem(value: '港股', child: Text('港股')),
                    DropdownMenuItem(value: '美股', child: Text('美股')),
                  ],
                  onChanged: loading ? null : (v) => setDialogState(() => market = v!),
                ),
              ] else if (isIndustry) ...[
                TextField(
                  controller: conceptController,
                  decoration: const InputDecoration(
                    labelText: '行业/概念',
                    hintText: '人工智能',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !loading,
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: loading
                  ? null
                  : () async {
                      if (isResearch && tickerController.text.trim().isEmpty) return;
                      if (isIndustry && conceptController.text.trim().isEmpty) return;
                      setDialogState(() => loading = true);
                      try {
                        final api = context.read<ApiService>();
                        final reportStore = context.read<ReportStore>();
                        await api.triggerResearch(
                          service: widget.serviceId,
                          ticker: tickerController.text.trim(),
                          market: market,
                          depth: depth,
                          concept: conceptController.text.trim(),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          await reportStore.fetchReports(widget.serviceId);
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          setDialogState(() => loading = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('触发失败: $e')),
                          );
                        }
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('开始'),
            ),
          ],
        ),
      ),
    );
  }
}
