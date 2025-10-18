import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/main/logic/main_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class MainViewAnnotatedRegion extends ConsumerWidget {
  final Widget child;
  const MainViewAnnotatedRegion({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    final Brightness brightness = ref.brightness;
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: ref.watch(MainProvider.isHomeScrolledProvider)
            ? theme.secondaryColor.withAlpha(100)
            : theme.background,
        statusBarBrightness: brightness,
        statusBarIconBrightness: brightness,
        systemNavigationBarIconBrightness: brightness,
        systemNavigationBarColor: ref.cardColor,
      ),

      child: child,
    );
  }
}
