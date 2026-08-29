import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/shared/widgets/layout/app_scaffold.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      title: "",
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset('assets/logo/splash.png', width: 150, height: 150),
        ),
      ),
    );
  }
}
