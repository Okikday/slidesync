import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopHomeView extends ConsumerWidget {
  const DesktopHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          ColoredBox(
            color: Colors.white,
            child: const SizedBox(width: 200, height: double.infinity),
          ),

          Expanded(child: const SizedBox()),

          ColoredBox(
            color: Colors.white,
            child: const SizedBox(width: 200, height: double.infinity),
          ),
        ],
      ),
    );
  }
}
