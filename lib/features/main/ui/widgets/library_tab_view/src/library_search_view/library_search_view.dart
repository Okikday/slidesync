import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:isar/isar.dart';
import 'package:slidesync/data/models/course_content/course_content.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/collection/ui/components/material_list_card.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';
import 'package:slidesync/shared/widgets/progress_indicator/circular_loading_indicator.dart';

class LibrarySearchView extends ConsumerStatefulWidget {
  const LibrarySearchView({super.key});

  @override
  ConsumerState<LibrarySearchView> createState() => _LibrarySearchViewState();
}

class _LibrarySearchViewState extends ConsumerState<LibrarySearchView> {
  late final TextEditingController searchTextController;
  dynamic filter;
  late final ValueNotifier<Future<List<CourseContent>>?> futureContentsNotifier;

  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
    futureContentsNotifier = ValueNotifier(null);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      filter = await CourseContentRepo.filter;
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ConstantSizing.columnSpacing(context.topPadding + kToolbarHeight),

            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: CustomTextfield(
                    controller: searchTextController,
                    autoDispose: false,
                    backgroundColor: theme.secondary.withAlpha(50),
                    inputContentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    inputTextStyle: TextStyle(color: theme.onBackground, fontSize: 15),
                    hint: "Search materials",
                    onchanged: (text) {
                      if (text.trim().isEmpty) {
                        if (futureContentsNotifier.value != null) {
                          futureContentsNotifier.value = CourseContentRepo.getAll();
                        }
                      } else {
                        futureContentsNotifier.value =
                            (filter as QueryBuilder<CourseContent, CourseContent, QFilterCondition>)
                                .titleContains(searchTextController.text, caseSensitive: false)
                                .findAll();
                      }
                    },
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(Iconsax.search_normal_copy),
                    ),
                  ),
                ),
                CloseButton(),
              ],
            ),

            Expanded(
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
                              return CircularLoadingIndicator(dimension: 30);
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
          ],
        ),
      ),
    );
  }
}
