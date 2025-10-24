import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:photo_view/photo_view.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/features/ask_ai/presentation/ui/ask_ai_screen.dart';
import 'package:slidesync/features/share/presentation/actions/share_content_actions.dart';
import 'package:slidesync/features/study/presentation/logic/image_viewer_provider.dart';
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
                      maxScale: 10.0,
                      onTapUp: (context, details, controllerValue) {
                        ref.read(imageViewerStateProvider).toggleAppBarVisible();
                      },
                      controller: ref.watch(imageViewerStateProvider.select((s) => s.controller)),
                      imageProvider: widget.content.path.fileDetails.containsFilePath
                          ? FileImage(File(widget.content.path.filePath))
                          : NetworkImage(widget.content.path.urlPath),
                      minScale: PhotoViewComputedScale.contained,
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
                              title: "Share",
                              iconData: Icons.share_rounded,
                              onTap: () async {
                                ShareContentActions.shareFileContent(context, widget.content.contentId);
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
