// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/data/models/course_model/course_content.dart';
// import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_search_controller.dart';
// import 'package:slidesync/features/study/presentation/controllers/src/pdf_doc_viewer_controller.dart';
// import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_viewer_inner_section.dart';
// import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';

// class PdfDocViewerStateLoader extends ConsumerWidget {
//   final CourseContent content;
//   // final Widget Function(PdfDocViewerState pdva, PdfDocSearchState pdsa) child;
//   const PdfDocViewerStateLoader({super.key, required this.content});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final pdvaN = ref.watch(PdfDocViewerController.pdfDocViewerStateProvider(content.contentId));
//     return pdvaN.when(
//       data: (pdva) {
//         final pdsaN = ref.watch(PdfDocSearchController.pdfDocSearchStateProvider(content.contentId));
//         return pdsaN.when(
//           data: (pdsa) {
//             log("rebuild state loader inner section");
//             return PdfDocViewerInnerSection(content: content, pdva: pdva, pdsa: pdsa);
//           },
//           error: (_, _) => Icon(Icons.error),
//           loading: () {
//             log("rebuild state loader");
//             return const Scaffold(
//               appBar: AppBarContainer(child: SizedBox()),
//               body: SizedBox(),
//             );
//           },
//         );
//       },
//       error: (_, _) => Icon(Icons.error),
//       loading: () {
//         log("rebuild state loader inner section");
//         return const Scaffold(
//           appBar: AppBarContainer(child: SizedBox()),
//           body: SizedBox(),
//         );
//       },
//     );
//   }
// }
