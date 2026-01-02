// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:pdfrx/pdfrx.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PdfLinkHandler {
//   static PdfLink? _lastTappedLink;
//   static Offset? _lastTapPosition;

//   /// Check if a tap position intersects with any link
//   static PdfLink? getLinkAtPosition(Offset tapPosition, Rect pageRect, PdfPage page, List<PdfLink> links) {
//     for (final link in links) {
//       // Check all rects in the link
//       for (final pdfRect in link.rects) {
//         final rect = pdfRect.toRectInDocument(page: page, pageRect: pageRect);
//         if (rect.contains(tapPosition)) {
//           return link;
//         }
//       }
//     }
//     return null;
//   }

//   /// Custom painter that draws transparent link areas
//   static void customLinkPainter(ui.Canvas canvas, Rect pageRect, PdfPage page, List<PdfLink> links) {
//     final paint = Paint()
//       ..color = Colors.transparent
//       ..style = PaintingStyle.fill;

//     for (final link in links) {
//       // Draw all rects for each link
//       for (final pdfRect in link.rects) {
//         final rect = pdfRect.toRectInDocument(page: page, pageRect: pageRect);
//         canvas.drawRect(rect, paint);
//       }
//     }
//   }

//   /// Handle link tap with position tracking
//   static void handleLinkTap(PdfLink link, Offset tapPosition, BuildContext context) async {
//     _lastTappedLink = link;
//     _lastTapPosition = tapPosition;

//     if (link.url != null) {
//       // External URL
//       debugPrint('External link tap: ${link.url}');
//       // UiUtils.showFlushBar(context, msg: "Opening link...");
//       await launchUrl(link.url!, mode: LaunchMode.platformDefault);
//     } else if (link.dest != null) {
//       // Internal destination - pdfrx handles this automatically
//       debugPrint('Internal link to page: ${link.dest?.pageNumber}');
//     }
//   }

//   /// Check if the last tap was on a link
//   static bool wasLinkTapped(Offset currentTapPosition, {Duration timeout = const Duration(milliseconds: 100)}) {
//     if (_lastTapPosition == null || _lastTappedLink == null) return false;

//     // Check if tap positions are close (within 10 pixels)
//     final distance = (_lastTapPosition! - currentTapPosition).distance;
//     if (distance < 10) {
//       // Clear after checking to prevent stale data
//       Future.delayed(timeout, () {
//         _lastTappedLink = null;
//         _lastTapPosition = null;
//       });
//       return true;
//     }

//     return false;
//   }

//   /// Clear link tap state
//   static void clearLinkTapState() {
//     _lastTappedLink = null;
//     _lastTapPosition = null;
//   }
// }

// // /// Extension to convert PdfRect to Rect in document coordinates
// // extension PdfRectExtension on PdfRect {
// //   Rect toRectInDocument({required PdfPage page, required Rect pageRect}) {
// //     final scaleX = pageRect.width / page.width;
// //     final scaleY = pageRect.height / page.height;
    
// //     return Rect.fromLTRB(
// //       pageRect.left + left * scaleX,
// //       pageRect.top + top * scaleY,
// //       pageRect.left + right * scaleX,
// //       pageRect.top + bottom * scaleY,
// //     );
// //   }
// // }