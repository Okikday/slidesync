import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class CreateCourseFAB extends ConsumerWidget {
  final bool pushToCreated;
  const CreateCourseFAB({super.key, this.pushToCreated = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return FloatingActionButton(
      onPressed: () => context.pushNamed(Routes.createCourse.name, extra: pushToCreated),
      tooltip: "Create course",
      shape: const CircleBorder(),
      backgroundColor: theme.primaryColor,
      child: ClipOval(
        child: ColoredBox(
          color: theme.primary,
          child: SizedBox.square(dimension: 51, child: Icon(HugeIconsSolid.add01, color: theme.onPrimary)),
        ),
      ),
    ).animate().scale(
      alignment: Alignment.bottomRight,
      curve: CustomCurves.bouncySpring,
      duration: Durations.extralong3,
    );
  }
}
