
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/domain/models/file_details.dart';
import 'package:slidesync/domain/models/course_model/course.dart';
import 'package:slidesync/features/manage_all/manage_contents/usecases/create_contents_uc/create_content_preview_image.dart';
import 'package:slidesync/shared/helpers/extension_helper.dart';
import 'package:slidesync/shared/helpers/formatter.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';
import 'package:slidesync/shared/styles/colors.dart';
import 'package:slidesync/shared/widgets/build_image_path_widget.dart';

class CourseMaterialListCard extends ConsumerStatefulWidget {
  final CourseContent courseContent;
  final void Function() onTapCard;
  final void Function()? onLongPressed;

  const CourseMaterialListCard({super.key, required this.courseContent, required this.onTapCard, this.onLongPressed});

  @override
  ConsumerState<CourseMaterialListCard> createState() => _CourseMaterialListCardState();
}

class _CourseMaterialListCardState extends ConsumerState<CourseMaterialListCard> with SingleTickerProviderStateMixin {
  late final ValueNotifier<bool> isCardExpandedNotifier;
  late AnimationController expandAnimationController;
  late Animation<double> expandAnim;

  @override
  void initState() {
    super.initState();
    isCardExpandedNotifier = ValueNotifier(false);
    isCardExpandedNotifier.addListener(cardExpandListener);
    expandAnimationController = AnimationController(
      vsync: this,
      duration: Durations.extralong2,
      reverseDuration: Durations.medium1,
    );
    expandAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: expandAnimationController,
        curve: CustomCurves.bouncySpring,
        reverseCurve: CustomCurves.defaultIosSpring,
      ),
    );
  }

  void cardExpandListener() {
    isCardExpandedNotifier.value ? expandAnimationController.forward() : expandAnimationController.reverse();
  }

  @override
  void dispose() {
    isCardExpandedNotifier.removeListener(cardExpandListener);
    isCardExpandedNotifier.dispose();
    expandAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    List<CourseMaterialListCardActionModel> courseMaterialListCardActionModels = [
      CourseMaterialListCardActionModel(label: "Open", icon: Icons.play_circle, onTap: () {}),
    ];
    

    final CourseContent courseContent = widget.courseContent;
    final theme = ref.theme;
    return AnimatedContainer(
      duration: Durations.extralong4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: theme.bgLightenColor(), borderRadius: BorderRadius.circular(12)),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          overlayColor: WidgetStatePropertyAll(theme.altBackgroundPrimary),
          onTap: widget.onTapCard,
          onLongPress: widget.onLongPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                        // boxShadow: [BoxShadow(color: theme.primaryColor.withAlpha(80), blurRadius: 2, spreadRadius: 2)],
                      ),
                      child: BuildImagePathWidget(
                        fileDetails: FileDetails(
                          filePath: CreateContentPreviewImage.genPreviewImagePath(
                            filePath: courseContent.path.filePath,
                          ),
                        ),
                        fallbackWidget: Icon(
                          WidgetHelper.resolveIconData(courseContent.courseContentType, true),
                          size: 20,
                        ),
                      ),
                    ),
                    ConstantSizing.rowSpacingMedium,
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 100),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: CustomText(
                                courseContent.title,
                                fontSize: 13,
                                color: theme.onBackground,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            // ConstantSizing.columnSpacing(2),
                            CustomText(
                              Formatter.formatEnumName(courseContent.courseContentType.name),
                              fontSize: 11,
                              color: theme.supportingText,
                            ),
                            // ConstantSizing.columnSpacing(8),
                            // LinearProgressIndicator(
                            //   minHeight: 8,
                            //   borderRadius: BorderRadius.circular(36),
                            //   value: math.Random().nextDouble(),
                            //   backgroundColor: Colors.black.withAlpha(40),
                            //   color: theme.primaryColor, //.withAlpha(40)
                            // ),
                          ],
                        ),
                      ),
                    ),
                    ConstantSizing.rowSpacingMedium,
                    // Icon(Iconsax.arrow_circle_right, color: theme.bgSupportingText),
                  ],
                ),

                SizeTransition(sizeFactor: expandAnim, child: ConstantSizing.columnSpacingMedium),

                AnimatedCourseMaterialListCardMenu(
                  courseMaterialListCardActionModels: courseMaterialListCardActionModels,
                  expandAnim: expandAnim,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedCourseMaterialListCardMenu extends ConsumerStatefulWidget {
  const AnimatedCourseMaterialListCardMenu({
    super.key,
    required this.courseMaterialListCardActionModels,
    required this.expandAnim,
  });

  final List<CourseMaterialListCardActionModel> courseMaterialListCardActionModels;
  final Animation<double> expandAnim;

  @override
  ConsumerState<AnimatedCourseMaterialListCardMenu> createState() => _AnimatedCourseMaterialListCardMenuState();
}

class _AnimatedCourseMaterialListCardMenuState extends ConsumerState<AnimatedCourseMaterialListCardMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.theme;
    return Builder(
      builder: (context) {
        final cam = widget.courseMaterialListCardActionModels;
        final List<Widget> genCardFuncs = List.generate(cam.length, (index) {
          return ScaleTransition(
            scale: widget.expandAnim,
            child: CustomElevatedButton(
              borderRadius: 24,
              backgroundColor: theme.primaryColor.withAlpha(40),
              onClick: cam[index].onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cam[index].icon, color: theme.supportingText),
                  ConstantSizing.rowSpacingSmall,
                  CustomText(cam[index].label, color: theme.onBackground),
                ],
              ),
            ),
          );
        });
        return SizeTransition(
          sizeFactor: widget.expandAnim,
          child: FadeTransition(
            opacity: widget.expandAnim,
            child: Padding(
              padding: EdgeInsets.only(left: context.deviceWidth * 0.2),
              child: Wrap(runAlignment: WrapAlignment.start, spacing: 8.0, runSpacing: 8.0, children: genCardFuncs),
            ),
          ),
        );
      },
    );
  }
}

// class CourseMaterialListCardModel {
//   final String title;
//   final double progress;
//   final Widget? previewImage;
//   final void Function()? onOpen;
//   final List<CourseMaterialListCardActionModel> CourseMaterialListCardActionModels;

//   CourseMaterialListCardModel({
//     required this.title,
//     required this.progress,
//     this.previewImage,
//     this.onOpen,
//     required this.CourseMaterialListCardActionModels,
//   });

//   CourseMaterialListCardModel copyWith({
//     String? title,
//     double? progress,
//     Widget? previewImage,
//     void Function()? onOpen,
//     List<CourseMaterialListCardActionModel>? CourseMaterialListCardActionModels,
//   }) {
//     return CourseMaterialListCardModel(
//       title: title ?? this.title,
//       progress: progress ?? this.progress,
//       previewImage: previewImage ?? this.previewImage,
//       onOpen: onOpen ?? this.onOpen,
//       CourseMaterialListCardActionModels: CourseMaterialListCardActionModels ?? this.CourseMaterialListCardActionModels,
//     );
//   }
// }

class CourseMaterialListCardActionModel {
  final String label;
  final IconData icon;
  final void Function() onTap;

  CourseMaterialListCardActionModel({required this.label, required this.icon, required this.onTap});

  CourseMaterialListCardActionModel copyWith({String? label, IconData? icon, void Function()? onTap}) {
    return CourseMaterialListCardActionModel(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
    );
  }
}
