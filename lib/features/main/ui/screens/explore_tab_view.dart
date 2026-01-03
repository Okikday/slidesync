import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:slidesync/features/main/providers/explore/explore_controller.dart';
import 'package:slidesync/features/main/ui/models/explore_card_data.dart';
import 'package:slidesync/features/main/ui/widgets/explore_tab_view/explore_card.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class ExploreTabView extends ConsumerStatefulWidget {
  const ExploreTabView({super.key});

  @override
  ConsumerState<ExploreTabView> createState() => _ExploreTabViewState();
}

class _ExploreTabViewState extends ConsumerState<ExploreTabView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final exploreState = ref.watch(exploreControllerProvider);
    final controller = ref.read(exploreControllerProvider.notifier);

    return TopPadding(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SmoothCustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: CustomText("Explore", fontSize: 24, color: theme.onBackground, fontWeight: FontWeight.bold),
                  ),
                  BuildButton(
                    onTap: () => context.pushNamed(Routes.sync.name),
                    iconData: Iconsax.settings,
                    backgroundColor: theme.onBackground.withAlpha(20),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

            // Search bar
            SliverToBoxAdapter(
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: CustomTextfield(
                      controller: _searchController,
                      hint: "Search ${exploreState.selectedType.name}s...",
                      autoDispose: false,
                      hintStyle: TextStyle(color: theme.supportingText),
                      selectionHandleColor: theme.primaryColor,
                      inputContentPadding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                      inputTextStyle: TextStyle(fontSize: 15, color: theme.onBackground),
                      cursorColor: theme.primaryColor,
                      backgroundColor: Colors.transparent,
                      border: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor, width: 1.5)),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 10, top: 12, bottom: 12),
                        child: Icon(Iconsax.search_normal_copy, size: 20, color: theme.supportingText),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                controller.updateSearchQuery('');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(Iconsax.close_circle, size: 20, color: theme.supportingText),
                              ),
                            )
                          : null,
                      onchanged: (text) {
                        controller.updateSearchQuery(text);
                        setState(() {}); // Update suffix icon
                      },
                    ),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

            // Type filter chips
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _TypeFilterChip(
                      label: 'Courses',
                      icon: Icons.school,
                      type: ExploreCardType.course,
                      isSelected: exploreState.selectedType == ExploreCardType.course,
                      onTap: () => controller.changeType(ExploreCardType.course),
                    ),
                    const SizedBox(width: 8),
                    _TypeFilterChip(
                      label: 'Collections',
                      icon: Icons.collections,
                      type: ExploreCardType.collection,
                      isSelected: exploreState.selectedType == ExploreCardType.collection,
                      onTap: () => controller.changeType(ExploreCardType.collection),
                    ),
                    const SizedBox(width: 8),
                    _TypeFilterChip(
                      label: 'Contents',
                      icon: Icons.description,
                      type: ExploreCardType.content,
                      isSelected: exploreState.selectedType == ExploreCardType.content,
                      onTap: () => controller.changeType(ExploreCardType.content),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: ConstantSizing.columnSpacingLarge),

            // Paginated list
            PagedSliverList<int, ExploreCardData>(
              state: controller.currentController.value,
              fetchNextPage: controller.fetchNextPage,
              builderDelegate: PagedChildBuilderDelegate<ExploreCardData>(
                itemBuilder: (context, item, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ExploreCard(
                      data: item,
                      onTap: () => _handleCardTap(context, item),
                      onAuthorTap: () => _handleAuthorTap(context, item),
                    ),
                  );
                },
                firstPageErrorIndicatorBuilder: (context) => _ErrorIndicator(
                  error: controller.currentController.error,
                  onRetry: () => controller.currentController.refresh(),
                ),
                // newPageErrorIndicatorBuilder: (context) => _ErrorIndicator(
                //   error: controller.currentController.error,
                //   onRetry: () => controller.currentController.refresh(),
                // ),
                firstPageProgressIndicatorBuilder: (context) => const Center(
                  child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
                ),
                newPageProgressIndicatorBuilder: (context) => const Center(
                  child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                ),
                noItemsFoundIndicatorBuilder: (context) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Iconsax.search_normal, size: 64, color: theme.supportingText),
                        const SizedBox(height: 16),
                        CustomText(
                          'No ${exploreState.selectedType.name}s found',
                          fontSize: 16,
                          color: theme.supportingText,
                          fontWeight: FontWeight.w500,
                        ),
                        if (exploreState.searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          CustomText('Try a different search term', fontSize: 14, color: theme.supportingText),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom padding
            SliverToBoxAdapter(child: ConstantSizing.columnSpacingLarge),
          ],
        ),
      ),
    );
  }

  void _handleCardTap(BuildContext context, ExploreCardData data) {
    // TODO: Navigate based on type
    switch (data.type) {
      case ExploreCardType.course:
        // Show download dialog for course
        _showDownloadDialog(context, data);
        break;
      case ExploreCardType.collection:
        // Show download dialog for collection
        _showDownloadDialog(context, data);
        break;
      case ExploreCardType.content:
        // Show download dialog for content
        _showDownloadDialog(context, data);
        break;
    }
  }

  void _handleAuthorTap(BuildContext context, ExploreCardData data) {
    // TODO: Navigate to author profile or show author info
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Author: ${data.authorName}')));
  }

  void _showDownloadDialog(BuildContext context, ExploreCardData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download ${data.typeLabel}?'),
        content: Text('Do you want to download "${data.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Integrate with SyncService to download
              _initiateDownload(data);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _initiateDownload(ExploreCardData data) {
    // TODO: Call appropriate SyncService method based on type
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${data.title}...')));
  }
}

/// Type filter chip widget
class _TypeFilterChip extends ConsumerWidget {
  final String label;
  final IconData icon;
  final ExploreCardType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeFilterChip({
    required this.label,
    required this.icon,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final color = isSelected ? theme.primary : theme.supportingText;
    final backgroundColor = isSelected ? theme.primary.withValues(alpha: 0.15) : theme.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.3) : theme.supportingText.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            CustomText(label, fontSize: 13, color: color, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500),
          ],
        ),
      ),
    );
  }
}

/// Error indicator widget
class _ErrorIndicator extends ConsumerWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _ErrorIndicator({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.danger, size: 64, color: Colors.red.withValues(alpha: 0.7)),
            const SizedBox(height: 16),
            CustomText('Something went wrong', fontSize: 16, color: theme.onBackground, fontWeight: FontWeight.w500),
            const SizedBox(height: 8),
            CustomText(
              error?.toString() ?? 'Unknown error',
              fontSize: 14,
              color: theme.supportingText,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Iconsax.refresh), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
