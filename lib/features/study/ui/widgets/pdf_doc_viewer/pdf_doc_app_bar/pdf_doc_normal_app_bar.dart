import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/collection/providers/collection_materials_provider.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/features/study/providers/pdf_doc_viewer_provider.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class PdfDocNormalAppBar extends ConsumerWidget {
  const PdfDocNormalAppBar({super.key, required this.contentId, required this.title, required this.onSearch});
  final String contentId;
  final String title;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Consumer(
      builder: (context, value, child) {
        final docViewP = PdfDocViewerProvider.searchState(contentId);
        return ValueListenableBuilder(
          valueListenable: ref.watch(docViewP.select((s) => s.isSearchingNotifier)),
          builder: (context, isSearching, child) {
            return AppBarContainerChild(
                  theme.isDarkMode,
                  title: title,
                  onBackButtonClicked: () async {
                    final content = await CourseContentRepo.getByContentId(contentId);
                    if (content != null) {
                      await Result.tryRunAsync(() async {
                        (await ref.read(
                          CollectionMaterialsProvider.contentPaginationProvider(content.parentId).future,
                        )).restartIsolate();
                      });
                    }
                    if (context.mounted) {
                      context.pop();
                    } else {
                      GlobalNav.withContext((c) => c.pop());
                    }
                  },
                  trailing: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        BuildButton(
                          iconData: Iconsax.search_normal_copy,
                          backgroundColor: Colors.transparent,
                          onTap: onSearch,
                        ),
                        AppPopupMenuButton(
                          tooltip: "More options",
                          constraints: BoxConstraints(maxWidth: 300),
                          actions: [
                            PopupMenuAction(
                              title: "Go to last page",
                              iconData: Iconsax.play,
                              onTap: () async {
                                final p = ref.read(PdfDocViewerProvider.state(contentId));
                                p.controller.goToPage(pageNumber: p.initialPage ?? 1);
                              },
                            ),
                            PopupMenuAction(
                              title: "Share",
                              iconData: Icons.share_rounded,
                              onTap: () async {
                                ShareContentActions.shareFileContent(context, contentId);
                              },
                            ),
                            // PopupMenuAction(
                            //   title: "Horizontal layout",
                            //   iconData: Iconsax.book_1,
                            //   onTap: () {
                            //     UiUtils.showFlushBar(context, msg: "Coming soon!");
                            //   },
                            // ),
                            () {
                              final isDarkMode = (ref.watch(PdfDocViewerProvider.ispdfViewerInDarkMode).value ?? false);
                              return PopupMenuAction(
                                title: isDarkMode ? "Normal mode(Light)" : "Inverted mode(Dark)",
                                iconData: isDarkMode ? Iconsax.sun_1 : Iconsax.moon,
                                onTap: () {
                                  ref.read(PdfDocViewerProvider.ispdfViewerInDarkMode.notifier).toggle();
                                },
                              );
                            }(),

                            // PopupMenuAction(
                            //   title: "Add current page to references",
                            //   iconData: Iconsax.book_1,
                            //   onTap: () async {
                            //     final content = await CourseContentRepo.getByContentId(contentId);
                            //     if (content == null) return;
                            //     final references = content.metadata['references'];
                            //     final currentPage = ref.read(PdfDocViewerProvider.state(contentId)).currentPageNumber;
                            //     // log("Got here");
                            //     final reference = content.copyWith(
                            //       contentHash: content.contentHash,
                            //       metadataJson: {
                            //         ...content.metadata,
                            //         'references': references == null
                            //             ? jsonEncode(<String>[currentPage.toString()])
                            //             : jsonEncode(<String>[
                            //                 ...(jsonDecode(references) as List<String>),
                            //                 currentPage.toString(),
                            //               ]),
                            //       }.encodeToJson,
                            //     );
                            //     await CourseCollectionRepo.addContentToAppCollection(
                            //       AppCourseCollections.references,
                            //       content: reference,
                            //     );
                            //   },
                            // ),
                            // PopupMenuAction(
                            //   title: "Try Quiz",
                            //   iconData: Iconsax.book_1,
                            //   onTap: () async {
                            //     final content = await CourseContentRepo.getByContentId(contentId);
                            //     if (content == null) return;

                            //     final fileSize = content.fileSize;
                            //     // 1 MB = 1,000,000 bytes
                            //     if (fileSize > 100000) {
                            //       GlobalNav.withContext(
                            //         (context) =>
                            //             UiUtils.showFlushBar(context, msg: "File is too big (must be under 100KB)"),
                            //       );
                            //       return;
                            //     }

                            //     final filePath = content.path.filePath;
                            //     final file = File(filePath);

                            //     if (!await file.exists()) {
                            //       GlobalNav.withContext(
                            //         (context) => UiUtils.showFlushBar(context, msg: "File not found"),
                            //       );
                            //       return;
                            //     }

                            //     GlobalNav.withContext(
                            //       (context) => UiUtils.showLoadingDialog(
                            //         context,
                            //         message: "Generating questions, may take a while",
                            //       ),
                            //     );
                            //     final bytes = await file.readAsBytes();
                            //     final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

                            //     final quizPrompt = QuestionPromptGenerator.forMaterial(questionLimit: 100);
                            //     log("Made prompt and asking ai");

                            //     final rawQuestions = await AiGenClient.instance.chatAnon([
                            //       Content('user', [TextPart(quizPrompt), InlineDataPart(mimeType, bytes)]),
                            //     ]);

                            //     log("Received response from ai");

                            //     final questions = QuestionParser.parse(rawQuestions);
                            //     final config = QuizScreenConfig(questions: questions);
                            //     GlobalNav.withContext((context) => context.pop());

                            //     GlobalNav.withContext(
                            //       (context) => Navigator.push(
                            //         context,
                            //         PageAnimation.pageRouteBuilder(QuizScreen(config: config)),
                            //       ),
                            //     );

                            //     final toStore = ContentQuestions.create(
                            //       contentHash: content.contentHash,
                            //       contentId: "${content.contentId}${DateTime.now().toIso8601String()}",
                            //       title: content.title,
                            //       questions: [rawQuestions],
                            //     );

                            //     await IsarData.instance<ContentQuestions>().store(toStore);
                            //   },
                            // ),
                          ],
                        ),

                        // Printing, Share, Save to Google drive
                      ],
                    ),
                  ),
                )
                .animate(target: isSearching ? 0 : 1)
                .slideY(begin: 1.0, end: 0.0, curve: CustomCurves.defaultIosSpring, duration: Durations.medium4)
                .fadeIn();
          },
        );
      },
    );
  }
}
