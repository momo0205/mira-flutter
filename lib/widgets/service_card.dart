import 'package:flutter/material.dart';
import '../models/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCard({super.key, required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.analytics_outlined, color: theme.colorScheme.primary),
        title: Text(service.name, style: theme.textTheme.titleMedium),
        subtitle: service.description != null
            ? Text(service.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
            : null,
        trailing: service.reportCount > 0
            ? Chip(
                label: Text('${service.reportCount} 篇报告'),
                visualDensity: VisualDensity.compact,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
