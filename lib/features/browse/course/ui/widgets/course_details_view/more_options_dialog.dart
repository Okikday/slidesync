import 'dart:math' as math;

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/apis/api.dart';
import 'package:slidesync/core/sync/entities/drive_progress.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/features/browse/course/ui/actions/modify_course_actions.dart';
import 'package:slidesync/features/browse/course/ui/widgets/shared/edit_course_bottom_sheet.dart';
import 'package:slidesync/features/share/ui/screens/export/course_export_manager.dart';
import 'package:slidesync/core/apis/abstract/sync_coordinator.dart';
import 'package:slidesync/features/sync/logic/notification_service.dart';
import 'package:slidesync/features/sync/providers/entities/sync_type.dart';
import 'package:slidesync/features/sync/providers/upload_feed_provider.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/features/browse/course/ui/widgets/course_details_view/course_details_header/animated_shape.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';

class MoreOptionsDialog extends ConsumerStatefulWidget {
  final Course course;

  const MoreOptionsDialog({super.key, required this.course});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MoreOptionsDialogState();
}

class _MoreOptionsDialogState extends ConsumerState<MoreOptionsDialog> {
  late final TextEditingController textEditingController;
  late final FocusNode focusNode;
  late final RoundedPolygon shape;
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    textEditingController.text = widget.course.title;
    focusNode = FocusNode();
    shape = materialShapes[math.Random().nextInt(materialShapes.length)].shape;
  }

  @override
  void dispose() {
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref;
    final course = widget.course;
    // final mca = ModifyCollectionActions();
    return AppActionDialog(
      blurSigma: Offset(4, 4),
      backgroundColor: theme.surface.withAlpha(200),

      leading: Padding(
        padding: const EdgeInsets.only(bottom: ConstantSizing.spaceMedium),
        child: Row(
          children: [
            ConstantSizing.rowSpacingMedium,

            Expanded(
              child: GestureDetector(
                onTap: () {
                  // CustomDialog.hide(context);
                  // UiUtils.showCustomDialog(context, child: EditCollectionTitleBottomSheet(collection: collection));
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CustomText(
                    course.courseName,
                    decorationColor: theme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.onBackground,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            ConstantSizing.rowSpacingMedium,
          ],
        ),
      ),
      actions: [
        // AppActionDialogModel(
        //   title: "Create a new collection",
        //   icon: Icon(HugeIconsSolid.addCircle, size: 24, color: theme.onBackground),
        //   onTap: () {
        //     context.pop();
        //     CourseDetailsActions.showNewCollectionDialog(context, course.courseId);
        //   },
        // ),
        AppActionDialogModel(
          title: "Edit Course",
          icon: Icon(HugeIconsSolid.edit01, size: 24, color: theme.onBackground),
          onTap: () async {
            context.pop();
            await showModalBottomSheet(
              context: context,
              enableDrag: false,
              showDragHandle: false,
              isScrollControlled: true,
              builder: (context) => EditCourseBottomSheet(courseId: course.uid),
            );
          },
        ),

        AppActionDialogModel(
          title: "See all collections",
          icon: Icon(HugeIconsSolid.magicWand01, size: 24, color: theme.onBackground),
          onTap: () {
            context.pop();
            context.pushNamed(Routes.collectionsView.name, extra: course.uid);
          },
        ),

        AppActionDialogModel(
          title: "Upload to Public repository",
          icon: Icon(Iconsax.export_1, size: 24, color: theme.onBackground),
          onTap: () async {
            context.pop();
            if (course.uid.isEmpty) return;

            final transferId = 'upload-course-${course.uid}-${DateTime.now().microsecondsSinceEpoch}';
            final transferNotifier = ref.read(transferStateProvider.notifier);
            final uploadFeedNotifier = ref.read(uploadFeedProvider.notifier);

            uploadFeedNotifier.start(
              id: transferId,
              title: 'Course: ${course.courseName}',
              type: SyncType.course,
              courseId: course.uid,
              logMessage: 'Queued upload to public repository',
            );
            transferNotifier.upsertTransfer(
              TransferState(
                id: transferId,
                title: 'Uploading ${course.courseName}',
                type: TransferType.course,
                direction: TransferDirection.upload,
                progress: 0.0,
                uploadedBytes: 0,
                totalBytes: 100,
                startedAt: DateTime.now(),
                status: TransferStatus.inProgress,
                sourceKey: course.uid,
              ),
            );
            uploadFeedNotifier.appendLog(transferId, 'Resolving account and vault links');

            try {
              // Get user ID
              final userIdResult = await UserDataFunctions().getUserId();
              if (!userIdResult.isSuccess || userIdResult.data == null) {
                transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
                uploadFeedNotifier.fail(transferId, 'User not authenticated');
                NotificationService.instance.showCompletion(
                  title: 'Upload failed',
                  body: 'Course ${course.courseName}: user not authenticated',
                );
                GlobalNav.withContext(
                  (context) => UiUtils.showFlushBar(context, msg: 'User not authenticated', vibe: FlushbarVibe.error),
                );
                return;
              }

              // Fetch vault links (admin only)
              final vaultResult = await Api.instance.vault.listVaults();
              if (!vaultResult.isSuccess || vaultResult.data == null || vaultResult.data!.isEmpty) {
                transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
                uploadFeedNotifier.fail(transferId, 'No vault links available');
                NotificationService.instance.showCompletion(
                  title: 'Upload failed',
                  body: 'Course ${course.courseName}: no vault links available',
                );
                GlobalNav.withContext(
                  (context) => UiUtils.showFlushBar(
                    context,
                    msg: 'No vault links available. Contact admin.',
                    vibe: FlushbarVibe.error,
                  ),
                );
                return;
              }

              // Extract URLs from vault entities
              final vaultLinks = vaultResult.data!.map((vault) => vault.url).toList();

              // Use SyncCoordinator to upload the course
              final coordinator = SyncCoordinator();
              uploadFeedNotifier.appendLog(transferId, 'Starting upload pipeline');
              final result = await coordinator.syncCourse(
                course: course,
                userId: userIdResult.data!,
                vaultLinks: vaultLinks,
                onProgress: (bytesTransferred, totalBytes) {
                  final safeTotal = totalBytes <= 0 ? 100 : totalBytes;
                  final safeTransferred = bytesTransferred.clamp(0, safeTotal);
                  final progress = safeTotal <= 0 ? 0.0 : safeTransferred / safeTotal;
                  transferNotifier.updateProgress(
                    id: transferId,
                    progress: progress,
                    uploadedBytes: safeTransferred,
                    totalBytes: safeTotal,
                  );
                  uploadFeedNotifier.updateProgress(
                    id: transferId,
                    progress: progress,
                    uploadedBytes: safeTransferred,
                    totalBytes: safeTotal,
                    logMessage:
                        'Uploaded ${DriveProgress.formatBytes(safeTransferred)} of ${DriveProgress.formatBytes(safeTotal)}',
                  );
                  NotificationService.instance.showUploadProgress(
                    id: transferId,
                    title: 'Course: ${course.courseName}',
                    progress: safeTransferred,
                    maxProgress: safeTotal,
                  );
                },
              );

              GlobalNav.withContext((context) {
                final data = result.data;
                if (data?.success ?? false) {
                  transferNotifier.updateProgress(id: transferId, progress: 1.0, uploadedBytes: 100, totalBytes: 100);
                  transferNotifier.updateStatus(id: transferId, status: TransferStatus.completed);
                  uploadFeedNotifier.complete(
                    transferId,
                    note: 'Uploaded ${data?.uploadedCount ?? 0} items • Skipped ${data?.skippedCount ?? 0}',
                    courseId: course.uid,
                  );
                  NotificationService.instance.cancel(transferId);
                  NotificationService.instance.showCompletion(
                    title: 'Upload completed',
                    body:
                        '${course.courseName}: Uploaded ${data?.uploadedCount ?? 0}, Skipped ${data?.skippedCount ?? 0}, Failed ${data?.failedCount ?? 0}',
                  );
                  UiUtils.showFlushBar(context, msg: 'Course uploaded successfully!');
                } else {
                  transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
                  uploadFeedNotifier.fail(transferId, result.data?.error ?? 'Upload failed');
                  NotificationService.instance.cancel(transferId);
                  NotificationService.instance.showCompletion(
                    title: 'Upload failed',
                    body: '${course.courseName}: ${result.data?.error ?? 'Upload failed'}',
                  );
                  UiUtils.showFlushBar(context, msg: result.data?.error ?? 'Upload failed', vibe: FlushbarVibe.error);
                }
              });
            } catch (e) {
              transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
              uploadFeedNotifier.fail(transferId, 'Upload failed: $e');
              NotificationService.instance.cancel(transferId);
              NotificationService.instance.showCompletion(title: 'Upload failed', body: '${course.courseName}: $e');
              GlobalNav.withContext(
                (context) => UiUtils.showFlushBar(context, msg: 'Upload failed: $e', vibe: FlushbarVibe.error),
              );
            } finally {
              transferNotifier.removeTransfer(transferId);
            }
          },
        ),

        AppActionDialogModel(
          title: "Export",
          icon: Icon(Iconsax.export_3, size: 24, color: Colors.blueAccent),
          titleColor: Colors.blueAccent,
          onTap: () async {
            context.pop();
            if (course.uid.isEmpty) return;
            CourseFolderExportManager.showExportScreen(context, course.uid);
          },
        ),
        AppActionDialogModel(
          title: "Delete",
          icon: Icon(Iconsax.box_remove_copy, size: 24, color: Colors.redAccent),
          titleColor: Colors.redAccent,
          onTap: () async {
            context.pop();
            if (course.uid.isEmpty) return;
            ModifyCourseActions().showDeleteCourseDialog(course.uid);
          },
        ),
      ],
    ).animate().fadeIn().scaleXY(
      begin: 0.6,
      end: 1,
      alignment: Alignment.topRight,
      duration: Durations.extralong1,
      curve: CustomCurves.defaultIosSpring,
    );
  }
}
