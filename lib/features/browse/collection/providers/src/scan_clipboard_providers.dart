// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/core/constants/constants.dart';
// import 'package:slidesync/core/utils/result.dart';
// import 'package:slidesync/features/manage/domain/usecases/contents/scan_clipboard_content_uc.dart';
// import 'package:slidesync/features/manage/presentation/contents/ui/add_contents/add_from_clipboard_dialog/add_from_clipboard_dialog.dart';

// class ScanClipboardProviders {
//   static final AsyncNotifierProvider<AppClipboardNotifier, AppClipboardData?> lastClipboardDataProvider =
//       AsyncNotifierProvider<AppClipboardNotifier, AppClipboardData?>(AppClipboardNotifier.new);

//   static final NotifierProvider<OverlayEntryNotifier, OverlayEntry?> addFromClipboardOverlayEntry =
//       NotifierProvider<OverlayEntryNotifier, OverlayEntry?>(OverlayEntryNotifier.new);
// }

// class AppClipboardNotifier extends AsyncNotifier<AppClipboardData?> {
//   @override
//   FutureOr<AppClipboardData?> build() async {
//     return null;
//   }

//   Future<void> scanClipboard(WidgetRef ref) async {
//     await Result.tryRunAsync(() async {
//       final context = ref.context;
//       final mounted = context.mounted;
//       final RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
//       if (rootIsolateToken == null) return;
//       final newClipboardData = await compute(ScanClipboardContentUc.scanClipboardForData, <String, dynamic>{
//         'token': rootIsolateToken,
//       });

//       if (!mounted) return;
//       final lastClipboardData = state.value;
//       if (lastClipboardData != null) {
//         if (ScanClipboardContentUc.isDataEqual(
//           lastClipboardData,
//           newClipboardData.data,
//           newClipboardData.contentType,
//         )) {
//           return;
//         } else {
//           if (!mounted) return;
//           update((cb) => newClipboardData);
//         }
//       } else {
//         if (!mounted) return;
//         update((cb) => newClipboardData);
//       }

//       if (!mounted) return;
//       final overlayEntryProvider = ref.read(ScanClipboardProviders.addFromClipboardOverlayEntry.notifier);

//       if (overlayEntryProvider.state != null) return;

//       final OverlayEntry addFromClipboardOverlayEntry = OverlayEntry(
//         builder: (context) => AddFromClipboardOverlay(clipboardData: newClipboardData),
//       );

//       if (!mounted) return;
//       overlayEntryProvider.update((cb) => addFromClipboardOverlayEntry);

//       if (context.mounted) {
//         final OverlayState overlay = Overlay.of(context);
//         overlay.insert(addFromClipboardOverlayEntry);
//       }
//     });
//   }
// }

// class OverlayEntryNotifier extends Notifier<OverlayEntry?> {
//   @override
//   OverlayEntry? build() => null;

//   void update(OverlayEntry? Function(OverlayEntry?) cb) {
//     final next = cb(state);
//     if (next == state) return;
//     state = next;
//   }
// }
