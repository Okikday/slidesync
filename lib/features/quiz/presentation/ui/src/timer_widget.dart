import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/quiz/presentation/logic/quiz_screen_state.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class TimerWidget extends ConsumerWidget {
  final QuizScreenState state;

  const TimerWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return ValueListenableBuilder<Duration?>(
      valueListenable: state.remainingTimeNotifier,
      builder: (context, remainingTime, _) {
        if (remainingTime == null) return const SizedBox.shrink();

        final minutes = remainingTime.inMinutes;
        final seconds = remainingTime.inSeconds % 60;
        final isWarning = remainingTime.inMinutes < 5;

        return Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isWarning ? Colors.red.withValues(alpha: 0.1) : theme.altBackgroundPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: isWarning ? Colors.red : theme.onSurface),
              const SizedBox(width: 6),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: isWarning ? Colors.red : theme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
