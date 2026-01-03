// browse_remote_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/logic/models/sync_model.dart';
import 'package:slidesync/features/sync/logic/sync_service.dart';

class BrowseRemoteView extends ConsumerStatefulWidget {
  const BrowseRemoteView({super.key});

  @override
  ConsumerState<BrowseRemoteView> createState() => _BrowseRemoteViewState();
}

class _BrowseRemoteViewState extends ConsumerState<BrowseRemoteView> {
  List<RemoteCourse> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final result = await SyncService.instance.listRemoteCourses();
    if (result.isSuccess && mounted) {
      setState(() {
        _courses = result.data!;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return ListTile(
          title: Text(course.courseTitle),
          subtitle: Text('${course.collectionsCount} collections'),
          onTap: () => _downloadCourse(course),
        );
      },
    );
  }

  Future<void> _downloadCourse(RemoteCourse course) async {
    // Show dialog, select target or create new
    // Then call SyncService.instance.downloadCourse(ref, ...)
  }
}
