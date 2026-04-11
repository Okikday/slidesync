import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/dev/file_manager_page.dart';

class SettingsRevealState {
  final int revealFileManagerCount;
  final DateTime? prevDateTime;

  const SettingsRevealState({this.revealFileManagerCount = 0, this.prevDateTime});

  SettingsRevealState copyWith({int? revealFileManagerCount, DateTime? prevDateTime}) {
    return SettingsRevealState(
      revealFileManagerCount: revealFileManagerCount ?? this.revealFileManagerCount,
      prevDateTime: prevDateTime ?? this.prevDateTime,
    );
  }

  @override
  bool operator ==(covariant SettingsRevealState other) {
    if (identical(this, other)) return true;

    return other.revealFileManagerCount == revealFileManagerCount && other.prevDateTime == prevDateTime;
  }

  @override
  int get hashCode => Object.hash(revealFileManagerCount, prevDateTime);
}

class SettingsRevealNotifier extends Notifier<SettingsRevealState> {
  @override
  SettingsRevealState build() => const SettingsRevealState();

  void _resetTracking() {
    state = SettingsRevealState(prevDateTime: DateTime.now(), revealFileManagerCount: 1);
  }

  void onRevealFileManager(BuildContext context) {
    log("clicked to reveal!");
    if (state.prevDateTime == null) {
      _resetTracking();
      return;
    } else {
      final currentTime = DateTime.now();
      final timeDiff = state.prevDateTime?.difference(currentTime);
      if (timeDiff == null || timeDiff.inMilliseconds > 800) {
        _resetTracking();
        return;
      }

      if (state.revealFileManagerCount >= 7) {
        Navigator.push(context, PageAnimation.pageRouteBuilder(FileManagerPage()));
        return;
      }

      state = state.copyWith(revealFileManagerCount: state.revealFileManagerCount + 1, prevDateTime: DateTime.now());
    }
  }
}
