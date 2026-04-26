import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:isar_community/isar.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_content_repo.dart';
import 'package:slidesync/features/browse/ui/widgets/module_contents_view/material_list_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/decorations/back_soft_edge_blur.dart';
import 'package:slidesync/shared/widgets/inputs/app_text_form_field.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/widgets/progress_indicator/app_circular_loading_indicator.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

class LibrarySearchView extends ConsumerStatefulWidget {
  const LibrarySearchView({super.key});

  @override
  ConsumerState<LibrarySearchView> createState() => _LibrarySearchViewState();
}

class _LibrarySearchViewState extends ConsumerState<LibrarySearchView> {
  late final TextEditingController searchTextController;
  dynamic filter;
  late final ValueNotifier<Future<List<ModuleContent>>?> futureContentsNotifier;

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
    futureContentsNotifier = ValueNotifier(null);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      filter = ModuleContentRepo.filter;
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    futureContentsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    return AppScaffold(
      title: "",
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBarPadding: (apply) => EdgeInsets.zero.copyWith(top: apply.top),
      appBar: BackSoftEdgeBlur(height: 40, applyHeightToSize: true, child: SizedBox()),
      body: TopPadding(
        child: BottomPadding(
          withHeight: 8,
          child: ValueListenableBuilder(
            valueListenable: futureContentsNotifier,
            builder: (context, futureContents, child) {
              return futureContents == null
                  ? Center(child: CustomText("Input a title to search", color: theme.onBackground))
                  : FutureBuilder(
                      future: futureContents,
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final contents = snapshot.data!;
                          return SmoothListView.builder(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 72),
                            itemCount: contents.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: MaterialListCard(content: contents[index], showGoToCollection: true),
                              );
                            },
                          );
                        } else if (snapshot.connectionState == ConnectionState.waiting ||
                            snapshot.connectionState == ConnectionState.active) {
                          return AppCircularLoadingIndicator(dimension: 30);
                        } else {
                          return Center(
                            child: CustomText(
                              "No results found for the ${searchTextController.text}",
                              color: theme.onBackground,
                            ),
                          );
                        }
                      },
                    );
            },
          ),
        ),
      ),

      footer: BackSoftEdgeBlur(
        edgeType: EdgeType.bottomEdge,
        applyHeightToSize: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: AppTextFormField(
                      controller: searchTextController,
                      // autoDispose: false,
                      fillColor: theme.background.withValues(alpha: 0.9),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      style: TextStyle(color: theme.onBackground, fontSize: 15),
                      borderRadius: 40,
                      borderSide: BorderSide(color: theme.onBackground.withValues(alpha: 0.15)),

                      hintText: "Search materials",
                      onChanged: (text) {
                        if (text.trim().isEmpty) {
                          if (futureContentsNotifier.value != null) {
                            futureContentsNotifier.value = ModuleContentRepo.getAll();
                          }
                        } else {
                          futureContentsNotifier.value =
                              (filter as QueryBuilder<ModuleContent, ModuleContent, QFilterCondition>)
                                  .titleContains(searchTextController.text, caseSensitive: false)
                                  .findAll();
                        }
                      },
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Icon(HugeIconsStroke.search02),
                      ),
                    ),
                  ),
                ),
              ),
              CloseButton(),
            ],
          ),
        ),
      ),
    );
  }
}
