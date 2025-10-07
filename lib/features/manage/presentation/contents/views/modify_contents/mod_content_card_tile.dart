import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/constants/src/enums.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/data/models/file_details.dart';
import 'package:slidesync/data/repos/course_repo/course_content_repo.dart';
import 'package:slidesync/features/browse/presentation/controlllers/src/content_card_controller.dart';
import 'package:slidesync/features/manage/presentation/contents/actions/modify_content_card_actions.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';
import 'package:slidesync/shared/widgets/buttons/app_popup_menu_button.dart';
import 'package:slidesync/shared/widgets/common/modifying_list_tile.dart';
import 'package:slidesync/shared/helpers/extensions/extension_helper.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_view.dart';

class ModContentCardTile extends ConsumerStatefulWidget {
  final CourseContent content;
  final bool? isSelected;

  /// This entails on click the icon or on long press
  final void Function()? onSelected;
  final void Function()? onTap;
  const ModContentCardTile({super.key, required this.content, this.isSelected, this.onSelected, this.onTap});

  @override
  ConsumerState<ModContentCardTile> createState() => _ModContentCardTileState();
}

class _ModContentCardTileState extends ConsumerState<ModContentCardTile> {
  late final StreamProvider contentProvider;
  @override
  void initState() {
    super.initState();
    contentProvider = StreamProvider.autoDispose((ref) async* {
      yield* CourseContentRepo.watchByDbId(widget.content.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final CourseContent content = ref.watch(contentProvider).value ?? widget.content;
    final previewDataProvider = ref.watch(ContentCardController.fetchLinkPreviewDataProvider(content));
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: ModifyingListTile(
        onTapTile: widget.onTap,
        leading: previewDataProvider.when(
          data: (data) => BuildImagePathWidget(
            fileDetails: data,
            fit: BoxFit.cover,
            fallbackWidget: Icon(WidgetHelper.resolveIconData(content.courseContentType, false), size: 36),
          ),
          error: (e, st) => BuildImagePathWidget(
            fileDetails: FileDetails(),
            fallbackWidget: Icon(WidgetHelper.resolveIconData(content.courseContentType, false), size: 36),
          ),
          loading: () => LoadingView(msg: ''),
        ),
        trailing: widget.isSelected == null
            ? AppPopupMenuButton(
                actions: [
                  PopupMenuAction(
                    title: "Select",
                    iconData: Iconsax.check,
                    onTap: () {
                      if (widget.onSelected != null) widget.onSelected!();
                    },
                  ),
                  if (content.courseContentType == CourseContentType.link)
                    PopupMenuAction(
                      title: "Copy",
                      iconData: Icons.copy,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: content.path.fileDetails.urlPath));
                      },
                    ),
                  PopupMenuAction(
                    title: "Rename",
                    iconData: Iconsax.edit,
                    onTap: () => ModifyContentCardActions.onRenameContent(context, content),
                  ),
                  PopupMenuAction(
                    title: "Delete",
                    iconData: Iconsax.trash,
                    onTap: () => ModifyContentCardActions.onDeleteContent(context, content),
                  ),
                ],
              )
            : (widget.isSelected!
                  ? Icon(Icons.check_circle_rounded, size: 32, color: ref.primary)
                  : Icon(Icons.circle, size: 32, color: ref.onSurface.withAlpha(150))),
        title: content.title,
        subtitle:
            widget.content.courseContentType.name.substring(0, 1).toUpperCase() +
            widget.content.courseContentType.name.substring(1),
      ),
    );
  }
}
