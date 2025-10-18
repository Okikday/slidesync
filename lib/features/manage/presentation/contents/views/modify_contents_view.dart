import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/manage/presentation/contents/controllers/src/modify_contents_controller.dart';
import 'package:slidesync/features/manage/presentation/contents/controllers/state/modify_contents_state.dart';
import 'package:slidesync/features/manage/presentation/contents/views/add_contents/add_content_fab.dart';
import 'package:slidesync/features/manage/presentation/contents/views/modify_contents/mod_content_search_view_button.dart';
import 'package:slidesync/features/manage/presentation/contents/views/modify_contents/modify_content_list_view.dart';
import 'package:slidesync/features/manage/presentation/contents/views/modify_contents/modify_contents_header.dart';
import 'package:slidesync/features/manage/presentation/contents/views/modify_contents/move_to_collection_bottom_sheet.dart';
import 'package:slidesync/shared/global/providers/collections_providers.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

class ModifyContentsView extends ConsumerStatefulWidget {
  final String collectionId;
  const ModifyContentsView({super.key, required this.collectionId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ModifyContentsViewState();
}

class _ModifyContentsViewState extends ConsumerState<ModifyContentsView> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final mcvp = ref.watch(ModifyContentsController.modifyContentsStateProvider);

    return ValueListenableBuilder(
      valueListenable: mcvp.selectedContentsNotifier,
      builder: (context, value, child) {
        return PopScope(
          canPop: value.isEmpty,
          onPopInvokedWithResult: (didPop, result) {
            if (!mcvp.isEmpty) {
              mcvp.clearContents();
            }
          },
          child: AnnotatedRegion(
            value: UiUtils.getSystemUiOverlayStyle(context.scaffoldBackgroundColor, context.isDarkMode),
            child: Scaffold(
              appBar: AppBarContainer(
                child: Consumer(
                  builder: (context, ref, child) {
                    final collectionTitleN = ref.watch(
                      CollectionsProviders.collectionProvider(
                        widget.collectionId,
                      ).select((c) => c.whenData((cb) => cb.collectionTitle)),
                    );

                    return collectionTitleN.when(
                      data: (data) {
                        return ValueListenableBuilder(
                          valueListenable: mcvp.selectedContentsNotifier,
                          builder: (context, value, child) {
                            return AppBarContainerChild(
                              context.isDarkMode,
                              title: data,
                              subtitle: value.isEmpty ? "Collection" : "${value.length} selected",
                              subtitleStyle: TextStyle(
                                fontSize: 12,
                                color: theme.background.lightenColor(theme.isDarkMode ? .4 : .6),
                              ),
                              trailing: child,
                            );
                          },
                          child: ModContentSearchViewButton(
                            doBeforeTap: () {
                              mcvp.clearContents();
                            },
                          ),
                        );
                      },
                      error: (_, _) => const Icon(Icons.error),
                      loading: () => AppBarContainerChild(
                        context.isDarkMode,
                        title: "__",
                        subtitle: "Collection",
                        subtitleStyle: TextStyle(
                          fontSize: 12,
                          color: theme.background.lightenColor(theme.isDarkMode ? .4 : .6),
                        ),
                      ),
                    );
                  },
                ),
              ),

              floatingActionButton: Consumer(
                builder: (context, ref, child) {
                  final collectionN = ref.watch(CollectionsProviders.collectionProvider(widget.collectionId));

                  return collectionN.when(
                    data: (data) {
                      return AddContentFAB(collection: data);
                    },
                    error: (_, _) => const Icon(Icons.error),
                    loading: () => FloatingActionButton(onPressed: () {}, child: LoadingLogo(size: 10)),
                  );
                },
              ),

              body: ModifyContentsOuterSection(collectionId: widget.collectionId, mcvp: mcvp),
            ),
          ),
        );
      },
    );
  }
}

class ModifyContentsOuterSection extends ConsumerWidget {
  final String collectionId;
  final ModifyContentsState mcvp;
  const ModifyContentsOuterSection({super.key, required this.collectionId, required this.mcvp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return CustomScrollView(
      slivers: [
        //collectionLength: record.collection.contents.length
        Consumer(
          child: const ModifyContentsHeader(collectionTitle: "__"),
          builder: (context, ref, child) {
            final collectionTitleN = ref.watch(
              CollectionsProviders.collectionProvider(
                collectionId,
              ).select((c) => c.whenData((cb) => cb.collectionTitle)),
            );
            return collectionTitleN.when(
              data: (data) {
                return ModifyContentsHeader(
                  collectionTitle: data,

                  onMoveContents: () async {
                    await showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      backgroundColor: theme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                      ),
                      builder: (context) {
                        return MoveToCollectionBottomSheet(contents: mcvp.selectedContentsNotifier.value.toList());
                      },
                    );
                  },
                );
              },
              error: (_, _) => Icon(Icons.error),
              loading: () => child!,
            );
          },
        ),
        SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

        ModifyContentListView(collectionId: collectionId),

        SliverToBoxAdapter(child: ConstantSizing.columnSpacing(context.bottomPadding)),
      ],
    );
  }
}
