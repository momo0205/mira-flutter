import 'package:flutter/material.dart';
import '../models/report.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ReportCard({
    super.key,
    required this.report,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: ListTile(
        contentPadding:
            const EdgeInsets.only(left: 16, right: 8, top: 6, bottom: 6),
        title: Text(
          report.title,
          style: theme.textTheme.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 12, color: theme.colorScheme.outline),
              const SizedBox(width: 4),
              Text(_formatDate(report.date),
                  style: theme.textTheme.bodySmall),
              if (report.tags.isNotEmpty) ...[
                const SizedBox(width: 12),
                ...report.tags.take(3).map((tag) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Text(
                        '#$tag',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )),
                if (report.tags.length > 3)
                  Text(
                    ' +${report.tags.length - 3}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
              ],
            ],
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : null,
          ),
          onPressed: onToggleFavorite,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
