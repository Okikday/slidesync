import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:slidesync/dev/sync_test/providers/sync_test_state.dart';

class SyncTestLogView extends ConsumerWidget {
  const SyncTestLogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(SyncTestProvider.state);
    final theme = Theme.of(context);

    if (state.logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: theme.colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No logs yet', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      reverse: true,
      itemCount: state.logs.length,
      itemBuilder: (context, index) {
        final log = state.logs[state.logs.length - 1 - index];
        return _buildLogEntry(context, log, theme);
      },
    );
  }

  Widget _buildLogEntry(BuildContext context, SyncTestLog log, ThemeData theme) {
    final timeFormat = DateFormat.Hms();
    final time = timeFormat.format(log.timestamp);

    final (icon, color, bgColor) = switch (log.level) {
      SyncLogLevel.info => (Icons.info, theme.colorScheme.primary, theme.colorScheme.primary),
      SyncLogLevel.success => (Icons.check_circle, Colors.green, Colors.green),
      SyncLogLevel.warning => (Icons.warning, Colors.orange, Colors.orange),
      SyncLogLevel.error => (Icons.error, Colors.red, Colors.red),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.message, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(time, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
