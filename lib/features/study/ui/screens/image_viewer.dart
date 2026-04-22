import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:photo_view/photo_view.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/ask_ai/ui/screens/ask_ai_screen.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/features/study/providers/image_viewer_provider.dart';
import 'package:slidesync/features/study/providers/src/pdf_doc_viewer_state/pdf_doc_viewer_state.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/shared/global/providers/collections_providers.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';

class ImageViewer extends ConsumerStatefulWidget {
  final ModuleContent content;
  const ImageViewer({super.key, required this.content});

  @override
  ConsumerState<ImageViewer> createState() => _ImageViewerState();
}

final _activeImageContentIdProvider = NotifierProvider<ImpliedNotifierN<String>, String?>(
  () => ImpliedNotifierN<String>(),
  isAutoDispose: true,
);
final _imageViewerPositionProvider = NotifierProvider<IntNotifier, int>(() => IntNotifier(0), isAutoDispose: true);

class _ImageViewerState extends ConsumerState<ImageViewer> {
  late final Future<Module> collectionFuture;
  late final PageController pageController;
  bool _isInitialJumpDone = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    collectionFuture = CourseCollectionRepo.getById(widget.content.parentId).then((c) => c ?? defaultCollection);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(theme.background, theme.isDarkMode),
      child: AppScaffold(
        title: "",
        body: FutureBuilder<Module>(
          future: collectionFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final contents = snapshot.data!.contents
                .where((c) => c.type == ModuleContentType.image)
                .toList()
                .reversed
                .toList();

            if (!_isInitialJumpDone && contents.isNotEmpty) {
              final startIndex = contents.indexWhere((c) => c.uid == widget.content.uid);
              final index = startIndex != -1 ? startIndex : 0;

              _isInitialJumpDone = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(_imageViewerPositionProvider.notifier).set(index);
                ref.read(_activeImageContentIdProvider.notifier).set(contents[index].uid);
                if (pageController.hasClients) pageController.jumpToPage(index);
              });
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Image View Layer
                Screenshot(
                  controller: PdfDocViewerState.screenshotController,
                  child: PageView.builder(
                    itemCount: contents.length,
                    controller: pageController,
                    onPageChanged: (value) {
                      ref.read(_imageViewerPositionProvider.notifier).set(value);
                      ref.read(_activeImageContentIdProvider.notifier).set(contents[value].uid);
                    },
                    itemBuilder: (context, index) {
                      final currContent = contents[index];
                      final stateProvider = ImageViewerProvider.state(currContent.uid);
                      final state = ref.read(stateProvider);

                      return FutureBuilder(
                        key: ValueKey(currContent.uid),
                        future: state.isInitialized,
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          return ValueListenableBuilder(
                            valueListenable: ref.watch(stateProvider.select((s) => s.isAppBarVisibleNotifier)),
                            builder: (context, isAppBarVisible, _) {
                              return _PhotoViewPadding(
                                isAppBarVisible: isAppBarVisible,
                                child: PhotoView(
                                  enablePanAlways: true,
                                  maxScale: 10.0,
                                  filterQuality: FilterQuality.high,
                                  minScale: PhotoViewComputedScale.contained,
                                  controller: ref.watch(stateProvider.select((s) => s.controller)),
                                  imageProvider: currContent.path.containsFilePath
                                      ? FileImage(File(currContent.path.local))
                                      : NetworkImage(currContent.path.url),
                                  onTapUp: (context, details, controllerValue) {
                                    ref.read(stateProvider).toggleAppBarVisible();
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // 2. AppBar Layer (Synced with current position)
                Consumer(
                  builder: (context, ref, _) {
                    final activeContentId = ref.watch(_activeImageContentIdProvider);
                    if (activeContentId == null) {
                      return AppBarContainer(child: AppBarContainerChild(theme.isDarkMode, title: "Loading..."));
                    }

                    final activeProvider = ImageViewerProvider.state(activeContentId);

                    return ValueListenableBuilder(
                      valueListenable: ref.watch(activeProvider.select((s) => s.isAppBarVisibleNotifier)),
                      builder: (context, isVisible, _) {
                        return Consumer(
                          builder: (context, ref, _) {
                            final pos = ref.watch(_imageViewerPositionProvider);
                            final currentItem = contents[pos];

                            return AppBarContainer(
                              appBarHeight: isVisible ? null : 0,
                              child: AppBarContainerChild(
                                theme.isDarkMode,
                                title: currentItem.title,
                                trailing: AppPopupMenuButton(
                                  actions: [
                                    PopupMenuAction(
                                      title: "Rotate Image",
                                      iconData: Iconsax.d_rotate,
                                      onTap: () => ref.read(activeProvider).setRotation(),
                                    ),
                                    PopupMenuAction(
                                      title: "Share",
                                      iconData: Icons.share_rounded,
                                      onTap: () => ShareContentActions.shareFileContent(context, currentItem.uid),
                                    ),
                                    PopupMenuAction(
                                      title: "Invoke Study AI",
                                      iconData: Iconsax.magic_star_copy,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          PageAnimation.pageRouteBuilder(
                                            AskAiScreen(contentId: currentItem.uid),
                                            type: TransitionType.none,
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
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
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
    return AnimatedPadding(
      duration: Durations.extralong1,
      curve: CustomCurves.defaultIosSpring,
      padding: EdgeInsets.only(top: isAppBarVisible ? kToolbarHeight + context.topPadding + 12 : 0),
      child: child,
    );
  }
}
