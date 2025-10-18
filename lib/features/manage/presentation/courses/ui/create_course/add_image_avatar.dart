import 'dart:io';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class AddImageAvatar extends ConsumerWidget {
  final NotifierProvider<ImpliedNotifierN<String>, String?> courseImagePathProvider;
  const AddImageAvatar({super.key, required this.courseImagePathProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? courseImagePath = ref.watch(courseImagePathProvider);
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
          child: InkWell(
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

              ref.read(courseImagePathProvider.notifier).update((cb) => pickedImage.path);

              if (context.mounted) UiUtils.showFlushBar(context, msg: "Selected course image!");
            },
            onLongPress: () {
              final currentPathNotifier = ref.read(courseImagePathProvider.notifier);
              if (courseImagePath == null) {
                UiUtils.showFlushBar(context, msg: "No course image was selected!");
              } else {
                currentPathNotifier.update((cb) => null);
                UiUtils.showFlushBar(context, msg: "Removed selected image!");
              }
            },
            child: courseImagePath == null
                ? Icon(Iconsax.folder_add, size: 72, color: theme.primaryColor)
                : Image.file(File(courseImagePath), fit: BoxFit.cover, width: imgRadius, height: imgRadius)
                      .animate()
                      .scale(
                        begin: Offset(0.4, 0.4),
                        duration: Durations.extralong4,
                        delay: Durations.medium1,
                        curve: CustomCurves.bouncySpring,
                      )
                      .moveY(begin: -20, duration: Durations.extralong4, delay: Durations.medium1),
          ),
        )
        .animate()
        .moveY(begin: -20, duration: Durations.medium2, delay: Durations.medium1, curve: CustomCurves.decelerate)
        .fadeIn(begin: 0.3, duration: Durations.medium2, delay: Durations.medium1, curve: CustomCurves.decelerate);
  }
}
