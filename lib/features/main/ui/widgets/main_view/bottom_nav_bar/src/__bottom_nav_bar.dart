part of '../bottom_nav_bar.dart';

class _SearchNavItem extends ConsumerWidget {
  const _SearchNavItem();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
        border: Border.all(
          color: theme.onBackground.withValues(alpha: 0.15),
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        shape: BoxShape.circle,
      ),
      child: CustomElevatedButton(
        fixedSize: Size.square(50),
        shape: CircleBorder(),
        backgroundColor: Colors.transparent,
        onClick: () {
          Navigator.push(
            context,
            PageAnimation.pageRouteBuilder(
              const LibrarySearchView(),
              curve: CustomCurves.defaultIosSpring,
              duration: 700.inMs,
              type: TransitionType.combine(
                transitions: [
                  TransitionType.scale(alignment: Alignment.bottomRight, from: 0.1),
                  TransitionType.fadeIn,
                ],
              ),
            ),
          );
        },
        child: Icon(HugeIconsSolid.search02, color: theme.onBackground, size: 25),
      ),
    );
  }
}

class _BuildNavItem extends StatelessWidget {
  final String label;
  final Widget icon;
  final String tooltip;
  final bool isActive;
  final Color labelColor;
  final void Function() onTap;
  const _BuildNavItem({
    required this.label,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
    required this.icon,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.longPress,
      message: tooltip,
      child: CustomElevatedButton(
        onClick: onTap,
        fixedSize: Size(72, 64),
        // minimumSize: Size(70, 64),
        borderRadius: 40,
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            ConstantSizing.columnSpacing(4),
            AppText(label, fontSize: 11, color: labelColor, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }
}
