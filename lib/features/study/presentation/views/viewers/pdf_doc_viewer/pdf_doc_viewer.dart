
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/data/models/course_model/course_content.dart';
import 'package:slidesync/features/study/presentation/views/viewers/pdf_doc_viewer/pdf_doc_viewer_inner_section.dart';

class PdfDocViewer extends ConsumerWidget {
  final CourseContent content;
  const PdfDocViewer({super.key, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PdfDocViewerInnerSection(content: content,);
  }
}
