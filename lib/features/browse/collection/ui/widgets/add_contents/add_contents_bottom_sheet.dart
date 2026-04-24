import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/features/browse/collection/ui/actions/add_contents_actions.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AddContentsBottomSheet extends ConsumerStatefulWidget {
  final Module collection;
  const AddContentsBottomSheet({super.key, required this.collection});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddContentsBottomSheetState();
}

class _AddContentsBottomSheetState extends ConsumerState<AddContentsBottomSheet> {
  late final FixedExtentScrollController fixedExtentScrollController;

  @override
  void initState() {
    super.initState();
    fixedExtentScrollController = FixedExtentScrollController(initialItem: 1);
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   ref.read(ScanClipboardProviders.lastClipboardDataProvider.notifier).scanClipboard(ref);
    // });
  }

  @override
  void dispose() {
    fixedExtentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final canPop = ref.watch(ScanClipboardProviders.addFromClipboardOverlayEntry) == null;
    return PopScope(
      // canPop: canPop,
      child: Stack(
        children: [
          Positioned.fill(child: GestureDetector(onTap: () => UiUtils.hideDialog(context))),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Align(
              alignment: Alignment.bottomCenter,
              child:
                  AddContentCardSection(
                        fixedExtentScrollController: fixedExtentScrollController,
                        collection: widget.collection,
                      )
                      .animate()
                      .scale(
                        alignment: Alignment.bottomRight,
                        begin: Offset(0.6, 0.6),
                        end: Offset(1, 1),
                        duration: 500.inMs,
                        curve: CustomCurves.defaultIosSpring,
                      )
                      .fadeIn(),
              // .scaleY(begin: canPop ? 0.8 : 1, end: canPop ? 1 : 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

typedef _CourseContentTypeDetails = ({String title, IconData icon});

class AddContentCardSection extends ConsumerWidget {
  const AddContentCardSection({super.key, required this.fixedExtentScrollController, required this.collection});

  final FixedExtentScrollController fixedExtentScrollController;
  final Module collection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const typesMap = <ModuleContentType, _CourseContentTypeDetails>{
      ModuleContentType.image: (title: "Image", icon: HugeIconsSolid.image01),
      ModuleContentType.unknown: (title: "Auto", icon: HugeIconsSolid.magicWand03),
      ModuleContentType.document: (title: "Document", icon: HugeIconsSolid.documentAttachment),
      ModuleContentType.link: (title: "Link", icon: HugeIconsSolid.link01),
    };

    final theme = ref;
    return Container(
      width: context.deviceWidth,
      constraints: BoxConstraints(maxWidth: 400, maxHeight: 340),
      margin: EdgeInsets.only(bottom: context.bottomPadding + context.viewInsets.bottom, left: 20, right: 20),
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(30),
        border: Border.fromBorderSide(BorderSide(color: theme.onBackground.withAlpha(20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: CustomText(
              "What would you like to add?",
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.onBackground,
            ).animate().fadeIn().slideX(begin: -0.05),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                child: CupertinoPicker(
                  itemExtent: 60,
                  offAxisFraction: -0.1,
                  scrollController: fixedExtentScrollController,
                  onSelectedItemChanged: (index) async {},
                  children: typesMap.entries
                      .map(
                        (e) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: BuildPlainActionButton(
                            title: e.value.title,
                            icon: Icon(e.value.icon, color: theme.primaryColor),
                            onTap: () =>
                                AddContentsActions.onClickToAddContent(context, collection: collection, type: e.key),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ).animate().fadeIn().scaleX(begin: 0.95),
            ],
          ),
        ],
      ),
    );
  }
}
