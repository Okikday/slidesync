import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CircularLoadingIndicator extends ConsumerWidget {
  final double dimension;
  const CircularLoadingIndicator({super.key, this.dimension = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [SizedBox.square(dimension: 20, child: CircularProgressIndicator())],
    );
  }
}
