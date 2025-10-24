import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/constants/constants.dart';
import 'package:slidesync/core/storage/isar_data/isar_data.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:photo_view/photo_view.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/models/progress_track_models/content_track.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/features/ask_ai/presentation/ui/ask_ai_screen.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/features/manage/domain/usecases/contents/create_content_preview_image.dart';
import 'package:slidesync/features/study/presentation/logic/image_viewer_provider.dart';
import 'package:slidesync/features/study/presentation/logic/src/image_viewer_state.dart';
import 'package:slidesync/features/study/presentation/logic/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';

class ImageViewer extends ConsumerStatefulWidget {
  final CourseContent content;
  const ImageViewer({super.key, required this.content});

  @override
  ConsumerState<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends ConsumerState<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final imageViewerStateProvider = ImageViewerProvider.state(widget.content.contentId);
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(theme.background, theme.isDarkMode),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder(
              future: ref.watch(imageViewerStateProvider.select((s) => s.isInitialized)),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState != ConnectionState.done) return const SizedBox();
                return Screenshot(
                  controller: PdfDocViewerState.screenshotController,
                  child: ValueListenableBuilder(
                    valueListenable: ref.watch(imageViewerStateProvider.select((s) => s.isAppBarVisibleNotifier)),
                    builder: (context, isAppBarVisible, child) {
                      return _PhotoViewPadding(isAppBarVisible: isAppBarVisible, child: child!);
                    },
                    child: PhotoView(
                      enablePanAlways: true,
                      // enableRotation: true,
                      onTapUp: (context, details, controllerValue) {
                        ref.read(imageViewerStateProvider).toggleAppBarVisible();
                      },
                      controller: ref.watch(imageViewerStateProvider.select((s) => s.controller)),
                      imageProvider: widget.content.path.fileDetails.containsFilePath
                          ? FileImage(File(widget.content.path.filePath))
                          : NetworkImage(widget.content.path.urlPath),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered,
                    ),
                  ),
                );
              },
            ),

            Positioned(
              top: 0,
              child: ValueListenableBuilder(
                valueListenable: ref.watch(imageViewerStateProvider.select((s) => s.isAppBarVisibleNotifier)),
                builder: (context, isAppBarVisible, child) {
                  return AppBarContainer(
                    appBarHeight: isAppBarVisible ? null : 0,
                    child: AppBarContainerChild(
                      theme.isDarkMode,
                      title: widget.content.title,
                      trailing: AppPopupMenuButton(
                        actions: [
                          PopupMenuAction(
                            title: "Rotate Image",
                            iconData: Iconsax.d_rotate,
                            onTap: () {
                              ref.read(imageViewerStateProvider).setRotation();
                            },
                          ),

                          PopupMenuAction(
                            title: "Invoke Study AI",
                            iconData: Iconsax.magic_star_copy,
                            onTap: () {
                              Navigator.push(
                                context,
                                PageAnimation.pageRouteBuilder(
                                  AskAiScreen(contentId: widget.content.contentId),
                                  type: TransitionType.none,
                                  reverseDuration: Durations.short1,
                                  opaque: false,
                                  barrierColor: theme.background.withAlpha(180),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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

class _PhotoViewPadding extends StatelessWidget {
  final bool isAppBarVisible;
  final Widget child;
  const _PhotoViewPadding({required this.isAppBarVisible, required this.child});

  @override
  Widget build(BuildContext context) {
    final topPadding = context.topPadding;
    return AnimatedPadding(
      duration: Durations.extralong1,
      curve: CustomCurves.defaultIosSpring,
      padding: EdgeInsets.only(top: isAppBarVisible ? kToolbarHeight + topPadding + 12 : 0),
      child: child,
    );
  }
}
