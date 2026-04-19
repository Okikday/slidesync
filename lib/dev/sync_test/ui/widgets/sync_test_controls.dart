import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/dev/sync_test/providers/sync_test_coordinator.dart';
import 'package:slidesync/dev/sync_test/providers/sync_test_state.dart';
import 'package:slidesync/dev/sync_test/ui/widgets/sync_test_input_dialog.dart';

class SyncTestControls extends ConsumerWidget {
  const SyncTestControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(SyncTestCoordinatorProvider.state);
    final theme = Theme.of(context);
    final isSyncing = ref.watch(SyncTestProvider.state.select((s) => s.isSyncing));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===== API PATHS TEST =====
          _buildSection(
            theme: theme,
            title: 'API Configuration',
            children: [
              _buildButton(
                theme: theme,
                label: 'Test API Paths',
                icon: Icons.route,
                onPressed: () => coordinator.testApiPaths(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== COURSE OPERATIONS =====
          _buildSection(
            theme: theme,
            title: 'Courses',
            children: [
              _buildButton(
                theme: theme,
                label: 'Get Course by ID',
                icon: Icons.book,
                onPressed: () => _showCourseIdInput(context, ref, (courseId) {
                  coordinator.testGetCourse(courseId);
                }),
              ),
              _buildButton(
                theme: theme,
                label: 'List All Courses',
                icon: Icons.list_alt,
                onPressed: () => coordinator.testListCourses(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== COLLECTION OPERATIONS =====
          _buildSection(
            theme: theme,
            title: 'Collections',
            children: [
              _buildButton(
                theme: theme,
                label: 'Get Collection by ID',
                icon: Icons.folder,
                onPressed: () => _showCollectionIdInput(context, ref, (collectionId) {
                  coordinator.testGetCollection(collectionId);
                }),
              ),
              _buildButton(
                theme: theme,
                label: 'List Collections by Course',
                icon: Icons.folder_open,
                onPressed: () => _showCourseIdInput(context, ref, (courseId) {
                  coordinator.testListCollections(courseId);
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== CONTENT OPERATIONS =====
          _buildSection(
            theme: theme,
            title: 'Contents',
            children: [
              _buildButton(
                theme: theme,
                label: 'Get Content by ID',
                icon: Icons.description,
                onPressed: () => _showContentIdInput(context, ref, (contentId) {
                  coordinator.testGetContent(contentId);
                }),
              ),
              _buildButton(
                theme: theme,
                label: 'List Contents by Collection',
                icon: Icons.list,
                onPressed: () => _showCollectionIdInput(context, ref, (collectionId) {
                  coordinator.testListContents(collectionId);
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== VAULT OPERATIONS =====
          _buildSection(
            theme: theme,
            title: 'Vault',
            children: [
              _buildButton(
                theme: theme,
                label: 'List All Vaults',
                icon: Icons.storage,
                onPressed: () => coordinator.testListVaults(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== FLAT QUERIES TEST =====
          _buildSection(
            theme: theme,
            title: 'Query Testing',
            children: [
              _buildButton(
                theme: theme,
                label: 'Test Flat Queries (by Course)',
                icon: Icons.search,
                onPressed: () => _showCourseIdInput(context, ref, (courseId) {
                  coordinator.testFlatCollectionQueries(courseId);
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ===== SYNC OPERATIONS =====
          _buildSection(
            theme: theme,
            title: 'Sync Operations',
            children: [
              _buildButton(
                theme: theme,
                label: 'Sync Course',
                icon: Icons.cloud_upload,
                isPrimary: true,
                onPressed: () => _showSyncInput(context, ref, (courseId, vaultLinks) {
                  coordinator.testSyncCourse(courseId, vaultLinks);
                }),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection({required ThemeData theme, required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildButton({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? theme.colorScheme.primary : null,
          foregroundColor: isPrimary ? theme.colorScheme.onPrimary : null,
        ),
        onPressed: onPressed,
      ),
    );
  }

  void _showCourseIdInput(BuildContext context, WidgetRef ref, Function(String) onSubmit) {
    showDialog(
      context: context,
      builder: (context) =>
          SyncTestInputDialog(title: 'Enter Course ID', hintText: 'e.g., course-123', onSubmit: onSubmit),
    );
  }

  void _showCollectionIdInput(BuildContext context, WidgetRef ref, Function(String) onSubmit) {
    showDialog(
      context: context,
      builder: (context) =>
          SyncTestInputDialog(title: 'Enter Collection ID', hintText: 'e.g., collection-456', onSubmit: onSubmit),
    );
  }

  void _showContentIdInput(BuildContext context, WidgetRef ref, Function(String) onSubmit) {
    showDialog(
      context: context,
      builder: (context) =>
          SyncTestInputDialog(title: 'Enter Content ID', hintText: 'e.g., content-789', onSubmit: onSubmit),
    );
  }

  void _showSyncInput(BuildContext context, WidgetRef ref, Function(String, List<String>) onSubmit) {
    showDialog(
      context: context,
      builder: (context) => SyncTestSyncInputDialog(onSubmit: onSubmit),
    );
  }
}
