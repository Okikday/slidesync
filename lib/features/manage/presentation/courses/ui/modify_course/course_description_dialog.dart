import 'dart:ui';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CourseDescriptionDialog extends ConsumerStatefulWidget {
  final String description;

  const CourseDescriptionDialog({super.key, required this.description});

  @override
  ConsumerState createState() => _CourseDescriptionDialogState();
}

class _CourseDescriptionDialogState extends ConsumerState<CourseDescriptionDialog> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => CustomDialog.hide(context),
            child: ColoredBox(color: Colors.black.withAlpha(100)),
          ),
        ),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              border: Border.fromBorderSide(BorderSide(color: ref.onBackground.withAlpha(40))),
            ),
            constraints: BoxConstraints(maxWidth: 500, minWidth: 200, maxHeight: 700, minHeight: 300),
            // height: context.deviceWidth > context.deviceHeight
            //     ? context.deviceHeight * 0.75
            //     : context.deviceWidth * 0.75,
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            clipBehavior: Clip.hardEdge,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: RawScrollbar(
                mainAxisMargin: 0,
                thumbColor: Colors.grey.withAlpha(60),
                padding: EdgeInsets.only(top: 64),
                thumbVisibility: true,
                controller: scrollController,
                radius: Radius.circular(12),
                thickness: 8,
                interactive: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstantSizing.columnSpacingSmall,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: CustomText(
                          "Course description",
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          textAlign: TextAlign.center,
                          color: ref.onBackground,
                        ),
                      ),
                    ),
                    ConstantSizing.columnSpacingSmall,
                    Divider(color: context.isDarkMode ? Colors.lightBlue.withAlpha(40) : Colors.grey.withAlpha(40)),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                        child: CustomText(
                          widget.description,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: ref.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
