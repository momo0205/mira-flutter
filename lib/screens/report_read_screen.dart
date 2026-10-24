import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../stores/report_store.dart';
import '../stores/favorite_store.dart';
import '../stores/recent_store.dart';

class ReportReadScreen extends StatefulWidget {
  final String serviceId;
  final String serviceName;
  final Report report;

  const ReportReadScreen({
    super.key,
    required this.serviceId,
    required this.report,
    this.serviceName = '',
  });

  @override
  State<ReportReadScreen> createState() => _ReportReadScreenState();
}

class _ReportReadScreenState extends State<ReportReadScreen> {
  String? _content;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final content = await context
          .read<ReportStore>()
          .fetchContent(widget.serviceId, widget.report.id);
      if (mounted) {
        setState(() {
          _content = content;
          _loading = false;
        });
        context.read<RecentStore>().add(
              reportId: widget.report.id,
              serviceId: widget.serviceId,
              serviceName: widget.serviceName,
              title: widget.report.title,
            );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite =
        context.watch<FavoriteStore>().isFavorite(widget.report.id);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.report.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_content != null)
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: '复制全文',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _content!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制到剪贴板')),
                );
              },
            ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : null,
            ),
            onPressed: () => context
                .read<FavoriteStore>()
                .toggle(
                    widget.report.id, widget.serviceId, widget.report.title),
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return _buildLoadingState(theme);
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error = null;
                  });
                  _load();
                },
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }
    final content = _content;
    if (content == null) {
      return const Center(child: Text('内容为空'));
    }
    return Markdown(
      data: content,
      selectable: true,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet(
        h1: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
        h2: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.secondary,
        ),
        h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        code: TextStyle(
          fontSize: 13,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
        codeblockDecoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        tableBorder: TableBorder.all(
          color: theme.colorScheme.outlineVariant,
        ),
        tableHead: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        tableBody: TextStyle(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            widget.report.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 14, color: theme.colorScheme.outline),
              const SizedBox(width: 6),
              Text(_formatDate(widget.report.date),
                  style: theme.textTheme.bodyMedium),
              if (widget.report.tags.isNotEmpty) ...[
                const SizedBox(width: 16),
                ...widget.report.tags.take(5).map((tag) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text('#$tag',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary)),
                    )),
              ],
            ],
          ),
          if (widget.report.summary != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            Text('摘要', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.report.summary!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 12),
                Text('正在加载完整报告...',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
