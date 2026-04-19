import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container_child.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/dev/sync_test/ui/widgets/sync_test_log_view.dart';
import 'package:slidesync/dev/sync_test/ui/widgets/sync_test_controls.dart';
import 'package:slidesync/dev/sync_test/providers/sync_test_state.dart';

class SyncTestPage extends ConsumerWidget {
  const SyncTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(SyncTestProvider.state);

    return AppScaffold(
      title: 'Sync Test Suite',
      appBar: AppBarContainer(
        child: AppBarContainerChild(
          context.isDarkMode,
          title: "Sync Test Suite",
          subtitle: state.isSyncing ? '${state.currentOperation}...' : 'Ready',
          onBackButtonClicked: () => Navigator.pop(context),
          trailing: state.logs.isNotEmpty
              ? TextButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear'),
                  onPressed: () => ref.read(SyncTestProvider.state.notifier).clearLogs(),
                )
              : null,
        ),
      ),
      body: state.isSyncing && state.uploadProgress != null
          ? _buildProgressView(context, state, theme)
          : _buildMainView(context, state, theme),
    );
  }

  Widget _buildMainView(BuildContext context, SyncTestState state, ThemeData theme) {
    return Column(
      children: [
        // Progress indicator if syncing
        if (state.isSyncing) LinearProgressIndicator(value: state.uploadProgress, minHeight: 4),
        // Stats bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  label: 'Total Logs',
                  value: state.logs.length.toString(),
                  theme: theme,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  label: 'Operations',
                  value: '${state.completedOperations}/${state.totalOperations}',
                  theme: theme,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  context,
                  label: 'Status',
                  value: state.isSyncing ? 'Running' : 'Ready',
                  theme: theme,
                  color: state.isSyncing ? theme.colorScheme.tertiary : theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        // Controls
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: SyncTestControls()),
        const SizedBox(height: 12),
        // Logs
        Expanded(child: const SyncTestLogView()),
      ],
    );
  }

  Widget _buildProgressView(BuildContext context, SyncTestState state, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 80, height: 80, child: CircularProgressIndicator(strokeWidth: 4)),
          const SizedBox(height: 24),
          Text(state.currentOperation ?? 'Processing...', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          if (state.uploadProgress != null)
            Column(
              children: [
                SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: state.uploadProgress, minHeight: 8),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${(state.uploadProgress! * 100).toStringAsFixed(1)}%', style: theme.textTheme.bodyMedium),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required ThemeData theme,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color.withOpacity(0.7))),
        ],
      ),
    );
  }
}
