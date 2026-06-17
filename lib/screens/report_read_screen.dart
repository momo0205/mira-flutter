import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../stores/report_store.dart';
import '../stores/favorite_store.dart';

class ReportReadScreen extends StatefulWidget {
  final String serviceId;
  final Report report;

  const ReportReadScreen({
    super.key,
    required this.serviceId,
    required this.report,
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
        context.watch<FavoriteStore>().isFavorite(widget.report.title);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.report.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite ? Colors.amber : null,
            ),
            onPressed: () =>
                context.read<FavoriteStore>().toggle(widget.report.title),
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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
              Text('加载失败\n$_error', textAlign: TextAlign.center),
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
    return Markdown(
      data: _content!,
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
}
