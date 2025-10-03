import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course_model/course_collection.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/providers/modify_contents_view_providers.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/add_contents/add_content_fab.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/modify_contents/empty_contents_view.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/modify_contents/mod_content_search_view_button.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/modify_contents/modify_content_list_view.dart';
import 'package:slidesync/features/manage_all/manage_contents/presentation/views/modify_contents/modify_contents_header.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class ModifyContentsView extends ConsumerStatefulWidget {
  final CourseCollection collection;
  const ModifyContentsView({super.key, required this.collection});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ModifyContentsViewState();
}

class _ModifyContentsViewState extends ConsumerState<ModifyContentsView> {
  late final ModifyContentsViewProviders mcvp;

  @override
  void initState() {
    super.initState();
    mcvp = ModifyContentsViewProviders.of(ref);
  }

  @override
  void dispose() {
    mcvp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;

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
                child: AppBarContainerChild(
                  context.isDarkMode,
                  title: widget.collection.collectionTitle,
                  subtitle: "Collection",
                  subtitleStyle: TextStyle(
                    fontSize: 12,
                    color: theme.background.lightenColor(theme.isDarkMode ? .4 : .6),
                  ),
                  trailing: ModContentSearchViewButton(
                    doBeforeTap: () {
                      mcvp.clearContents();
                    },
                  ),
                ),
              ),

              floatingActionButton: AddContentFAB(collection: widget.collection),

              body: ModifyContentsOuterSection(mcvp: mcvp, collection: widget.collection),
            ),
          ),
        );
      },
    );
  }
}

class ModifyContentsOuterSection extends ConsumerWidget {
  final CourseCollection collection;
  final ModifyContentsViewProviders mcvp;
  const ModifyContentsOuterSection({super.key, required this.collection, required this.mcvp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return CustomScrollView(
      slivers: [
        //collectionLength: record.collection.contents.length
        ModifyContentsHeader(
          collectionTitle: collection.collectionTitle,
          mcvp: mcvp,
          onMoveContents: () async {
            await showModalBottomSheet(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              shape: BeveledRectangleBorder(
                side: const BorderSide(),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              builder: (context) {
                return DraggableScrollableSheet(
                  builder: (context, scrollController) {
                    return Column(
                      children: [
                        CustomText(
                          "Available courses",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.onBackground,
                        ),

                        ConstantSizing.columnSpacingExtraLarge,

                        
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
        SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),
        if (collection.contents.isEmpty)
          EmptyContentsView(collection: collection)
        else
          ModifyContentListView(
            mcvp: mcvp,
            collectionId: collection.collectionId,
            contentList: collection.contents.toList(),
          ),

        SliverToBoxAdapter(child: ConstantSizing.columnSpacing(context.bottomPadding)),
      ],
    );
  }
}
