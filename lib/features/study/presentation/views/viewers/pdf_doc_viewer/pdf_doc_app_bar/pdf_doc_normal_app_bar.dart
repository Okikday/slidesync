import 'dart:developer';
import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/presentation/controlllers/src/course_materials_controller/course_materials_controller.dart';
import 'package:slidesync/features/main/presentation/library/views/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/features/share/presentation/actions/share_content_actions.dart';
import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_search_state.dart';
import 'package:slidesync/features/study/presentation/controllers/state/pdf_doc_viewer_state.dart';
import 'package:slidesync/features/share/domain/usecases/share_content_uc.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';

class PdfDocNormalAppBar extends ConsumerWidget {
  const PdfDocNormalAppBar({
    super.key,
    required this.title,
    required this.pdva,
    required this.pdsa,
    required this.onSearch,
  });

  final String title;
  final PdfDocViewerState pdva;
  final PdfDocSearchState pdsa;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return ValueListenableBuilder(
      valueListenable: pdsa.isSearchingNotifier,
      builder: (context, value, child) {
        return AppBarContainerChild(
              theme.isDarkMode,
              title: title,
              onBackButtonClicked: () async {
                final content = await CourseContentRepo.getByContentId(pdva.contentId);
                if (content != null) {
                  (await ref.read(
                    CourseMaterialsController.contentPaginationProvider(content.parentId).future,
                  )).restartIsolate();
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
                      actions: [
                        PopupMenuAction(
                          title: "Go to last page",
                          iconData: Iconsax.play,
                          onTap: () {
                            pdva.pdfViewerController.goToPage(pageNumber: pdva.initialPage);
                          },
                        ),
                        PopupMenuAction(
                          title: "Share",
                          iconData: Icons.share_rounded,
                          onTap: () async {
                            ShareContentActions.shareFileContent(context, pdva.contentId);
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
                          final isDarkMode = (ref.watch(PdfDocViewerController.ispdfViewerInDarkMode).value ?? false);
                          return PopupMenuAction(
                            title: isDarkMode ? "Normal mode(Light)" : "Inverted mode(Dark)",
                            iconData: isDarkMode ? Iconsax.sun_1 : Iconsax.moon,
                            onTap: () {
                              ref.read(PdfDocViewerController.ispdfViewerInDarkMode.notifier).toggle();
                            },
                          );
                        }(),

                        PopupMenuAction(
                          title: "Enable AI button",
                          iconData: Iconsax.book_1,
                          onTap: () {
                            UiUtils.showFlushBar(context, msg: "Coming soon!");
                          },
                        ),
                      ],
                    ),

                    // Printing, Share, Save to Google drive
                  ],
                ),
              ),
            )
            .animate(target: value ? 0 : 1)
            .scale(
              begin: Offset(0, 0),
              end: Offset(1, 1),
              alignment: Alignment.bottomRight,
              curve: CustomCurves.defaultIosSpring,
              duration: Durations.medium4,
            )
            .fadeIn();
      },
    );
  }
}
