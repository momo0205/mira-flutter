import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mira_flutter/widgets/empty_state.dart';

void main() {
  testWidgets('renders message and icon', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(icon: Icons.inbox, message: '暂无数据'),
        ),
      ),
    );
    expect(find.text('暂无数据'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
  });

  testWidgets('renders action button when provided', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.error,
            message: '出错了',
            actionLabel: '重试',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );
    expect(find.text('重试'), findsOneWidget);
    await tester.tap(find.text('重试'));
    expect(tapped, isTrue);
  });

  testWidgets('no action button when not provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(icon: Icons.cloud_off, message: '离线'),
        ),
      ),
    );
    expect(find.byType(FilledButton), findsNothing);
  });
}
