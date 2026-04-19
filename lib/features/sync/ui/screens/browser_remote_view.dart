// browse_remote_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';

class BrowseRemoteView extends ConsumerStatefulWidget {
  const BrowseRemoteView({super.key});

  @override
  ConsumerState<BrowseRemoteView> createState() => _BrowseRemoteViewState();
}

class _BrowseRemoteViewState extends ConsumerState<BrowseRemoteView> {
  bool _isLoading = true;
  List<String> _remoteCourses = [];

  @override
  void initState() {
    super.initState();
    _loadRemoteCourses();
  }

  Future<void> _loadRemoteCourses() async {
    try {
      // TODO: Fetch remote courses from Firebase/API
      // For now, this is a placeholder
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isLoading = false;
          _remoteCourses = [];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_remoteCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, size: 48, color: theme.primaryColor),
              const SizedBox(height: 16),
              CustomText('No Remote Courses', fontSize: 18, fontWeight: FontWeight.w600, color: theme.onBackground),
              const SizedBox(height: 8),
              CustomText(
                'No courses found on remote',
                fontSize: 12,
                color: theme.supportingText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _remoteCourses.length,
      itemBuilder: (context, index) {
        final courseName = _remoteCourses[index];
        return ListTile(
          title: Text(courseName),
          trailing: Icon(Icons.download_outlined),
          onTap: () => _downloadCourse(courseName),
        );
      },
    );
  }

  void _downloadCourse(String courseName) {
    // TODO: Implement download functionality
    // 1. Create a new TransferState with TransferDirection.download
    // 2. Add to transferStateProvider
    // 3. Call DioDownloadManager to start download
    final transferId = '$courseName-${DateTime.now().millisecondsSinceEpoch}';

    final transfer = TransferState(
      id: transferId,
      title: 'Downloading $courseName',
      type: TransferType.course,
      direction: TransferDirection.download,
      progress: 0.0,
      uploadedBytes: 0,
      totalBytes: 0,
      startedAt: DateTime.now(),
      status: TransferStatus.pending,
    );

    ref.read(transferStateProvider.notifier).upsertTransfer(transfer);
  }
}
