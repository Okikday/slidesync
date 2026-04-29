import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class AddImageAvatar extends ConsumerWidget {
  final ValueNotifier<String?> courseImagePathNotifier;
  const AddImageAvatar({super.key, required this.courseImagePathNotifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double imgRadius = context.deviceHeight > context.deviceWidth
        ? context.deviceWidth * 0.4
        : context.deviceHeight * 0.4;
    final theme = ref;

    return Container(
          width: imgRadius,
          height: imgRadius,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            gradient: SweepGradient(colors: theme.backgroundGradientColors),
            shape: BoxShape.circle,
          ),
          child: ValueListenableBuilder(
            valueListenable: courseImagePathNotifier,
            builder: (context, courseImagePath, child) {
              return InkWell(
                customBorder: CircleBorder(),
                onTap: () async {
                  UiUtils.showLoadingDialog(
                    context,
                    message: "Selecting image...",
                    backgroundColor: Colors.white10,
                    blurSigma: Offset(2, 2),
                  );
                  ImagePicker imagePicker = ImagePicker();
                  final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
                  if (context.mounted) UiUtils.hideDialog(context);
                  if (pickedImage == null) {
                    if (context.mounted) UiUtils.showFlushBar(context, msg: "Oops, you didn't select an image");
                    return;
                  }

                  courseImagePathNotifier.value = pickedImage.path;

                  if (context.mounted) UiUtils.showFlushBar(context, msg: "Selected course image!");
                },
                onSecondaryTap: () {
                  if (courseImagePath == null) {
                    UiUtils.showFlushBar(context, msg: "No course image was selected!");
                  } else {
                    courseImagePathNotifier.value = null;
                    UiUtils.showFlushBar(context, msg: "Removed selected image!");
                  }
                },
                onLongPress: () {
                  if (courseImagePath == null) {
                    UiUtils.showFlushBar(context, msg: "No course image was selected!");
                  } else {
                    courseImagePathNotifier.value = null;
                    UiUtils.showFlushBar(context, msg: "Removed selected image!");
                  }
                },
                child: courseImagePath == null
                    ? Icon(Iconsax.folder_add, size: 72, color: theme.primaryColor)
                    : Image(
                            image: VersionedFileImage(
                              File(courseImagePath),
                              version: fileImageVersion(File(courseImagePath)),
                            ),
                            fit: BoxFit.cover,
                            width: imgRadius,
                            height: imgRadius,
                          )
                          .animate()
                          .scale(
                            begin: Offset(0.4, 0.4),
                            duration: Durations.extralong4,
                            delay: Durations.medium1,
                            curve: CustomCurves.bouncySpring,
                          )
                          .moveY(begin: -20, duration: Durations.extralong4, delay: Durations.medium1),
              );
            },
          ),
        )
        .animate()
        .moveY(begin: -20, duration: Durations.medium2, delay: Durations.medium1, curve: CustomCurves.decelerate)
        .fadeIn(begin: 0.3, duration: Durations.medium2, delay: Durations.medium1, curve: CustomCurves.decelerate);
  }
}
