import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroine/heroine.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/core/sync/entities/drive_progress.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/core/apis/api.dart';
import 'package:slidesync/core/apis/abstract/sync_coordinator.dart';
import 'package:slidesync/data/models/module_content/module_content.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';
import 'package:slidesync/features/browse/collection/providers/collection_materials_provider.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_content_card_actions.dart';
import 'package:slidesync/features/browse/collection/ui/actions/modify_contents_action.dart';
import 'package:slidesync/features/share/ui/actions/share_content_actions.dart';
import 'package:slidesync/features/study/ui/actions/content_view_gate_actions.dart';
import 'package:slidesync/features/sync/logic/notification_service.dart';
import 'package:slidesync/features/sync/providers/sync_provider.dart';
import 'package:slidesync/features/sync/providers/transfer_state_provider.dart';
import 'package:slidesync/features/sync/providers/upload_feed_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/helpers/widget_helper.dart';
import 'package:slidesync/shared/widgets/dialogs/app_action_dialog.dart';
import 'package:slidesync/shared/widgets/dialogs/confirm_deletion_dialog.dart';
import 'package:slidesync/shared/widgets/z_rand/build_image_path_widget.dart';

class ContentCardContextMenu extends ConsumerStatefulWidget {
  final ModuleContent content;
  const ContentCardContextMenu({super.key, required this.content});

  @override
  ConsumerState<ContentCardContextMenu> createState() => _ContentCardContextMenuState();
}

class _ContentCardContextMenuState extends ConsumerState<ContentCardContextMenu> {
  @override
  Widget build(BuildContext context) {
    final theme = ref;

    var divider = Divider(color: theme.onSurface.withAlpha(20), height: 0);

    return Stack(
      children: [
        Positioned.fill(
          child: SizedBox.expand(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Material(
              type: MaterialType.transparency,
              child: Heroine(
                tag: widget.content.uid,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  constraints: BoxConstraints(maxWidth: 300),
                  decoration: BoxDecoration(
                    color: theme.background.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.fromBorderSide(
                      BorderSide(color: theme.supportingText.withAlpha(40), strokeAlign: BorderSide.strokeAlignOutside),
                    ),
                  ),
                  padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          spacing: 8,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: theme.onSurface.withAlpha(20),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: BuildImagePathWidget(
                                fileDetails: widget.content.thumbnailDetails,
                                fallbackWidget: Icon(WidgetHelper.resolveIconData(widget.content.type), size: 20),
                              ),
                            ),
                            Expanded(
                              child: CustomText(
                                widget.content.title,
                                fontSize: 14,
                                color: theme.onSurface,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ConstantSizing.columnSpacingMedium,
                      divider,
                      ConstantSizing.columnSpacingSmall,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildLeadingMenuOption(
                              "Open",
                              iconData: HugeIconsStroke.playCircle,
                              onTap: () {
                                Navigator.pop(context);
                                ContentViewGateActions.redirectToViewer(ref, widget.content, openOutsideApp: false);
                              },
                            ),
                            widget.content.type == ModuleContentType.link
                                ? _buildLeadingMenuOption(
                                    "Copy",
                                    iconData: HugeIconsStroke.copyLink,
                                    onTap: () {
                                      Navigator.pop(context);
                                      final url = widget.content.path.url;
                                      if (url != null) {
                                        Clipboard.setData(ClipboardData(text: url));
                                        UiUtils.showFlushBar(context, msg: "Link copied to clipboard");
                                      }
                                    },
                                  )
                                : _buildLeadingMenuOption(
                                    "Launch",
                                    iconData: HugeIconsStroke.sendToMobile,
                                    onTap: () {
                                      Navigator.pop(context);
                                      ContentViewGateActions.redirectToViewer(
                                        ref,
                                        widget.content,
                                        openOutsideApp: true,
                                      );
                                    },
                                  ),
                            _buildLeadingMenuOption(
                              "Share",
                              iconData: HugeIconsStroke.share01,
                              onTap: () {
                                Navigator.pop(context);
                                ShareContentActions.shareContent(context, widget.content.uid);
                              },
                            ),
                          ],
                        ),
                      ),
                      divider,
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BuildPlainActionButton(
                              title: "Select",
                              icon: Icon(HugeIconsStroke.checkmarkCircle01, color: theme.onSurface),
                              onTap: () {
                                ref.read(CollectionMaterialsProvider.modState.notifier).selectContent(widget.content);
                                Navigator.pop(context);
                              },
                            ),
                            divider,
                            BuildPlainActionButton(
                              title: "Rename",
                              icon: Icon(HugeIconsStroke.cursorEdit01, color: theme.onSurface),
                              onTap: () {
                                Navigator.pop(context);
                                ModifyContentCardActions.onRenameContent(context, widget.content);
                              },
                            ),
                            divider,
                            BuildPlainActionButton(
                              title: "Upload",
                              icon: Icon(HugeIconsStroke.cursorEdit01, color: theme.onSurface),
                              onTap: () async {
                                Navigator.pop(context);
                                await _uploadContentToPublicRepository();
                              },
                            ),
                            divider,
                            BuildPlainActionButton(
                              title: "Delete",
                              textStyle: TextStyle(fontSize: 14, color: Colors.red),
                              icon: Icon(HugeIconsSolid.delete02, color: Colors.red.withAlpha(200)),
                              onTap: () {
                                Navigator.pop(context);
                                UiUtils.showCustomDialog(
                                  context,
                                  child: ConfirmDeletionDialog(
                                    content: "Are you sure you want to delete this item?",
                                    onPop: () {
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      } else {
                                        GlobalNav.popGlobal();
                                      }
                                    },
                                    onCancel: () {
                                      GlobalNav.popGlobal();
                                    },
                                    onDelete: () async {
                                      Navigator.pop(context);

                                      if (context.mounted) {
                                        UiUtils.showLoadingDialog(context, message: "Removing content");
                                      }
                                      final outcome = await ModifyContentsAction().onDeleteContent(widget.content.uid);

                                      GlobalNav.popGlobal();

                                      if (context.mounted) {
                                        if (outcome == null) {
                                          UiUtils.showFlushBar(
                                            context,
                                            msg: "Deleted content!",
                                            vibe: FlushbarVibe.success,
                                          );
                                        } else if (outcome.toLowerCase().contains("error")) {
                                          UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.error);
                                        } else {
                                          UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.warning);
                                        }
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // .animate().fadeIn().scaleXY(
                //   alignment: Alignment.topCenter,
                //   begin: 0.4,
                //   end: 1,
                //   curve: CustomCurves.defaultIosSpring,
                //   duration: Duration(milliseconds: 550),
                // ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _uploadContentToPublicRepository() async {
    final content = widget.content;
    final transferId = 'upload-content-${content.uid}-${DateTime.now().microsecondsSinceEpoch}';
    final transferNotifier = ref.read(transferStateProvider.notifier);
    final uploadFeedNotifier = ref.read(uploadFeedProvider.notifier);

    uploadFeedNotifier.start(
      id: transferId,
      title: content.title,
      type: SyncType.content,
      contentId: content.uid,
      collectionId: content.parentId,
      logMessage: 'Queued upload to public repository',
    );
    transferNotifier.upsertTransfer(
      TransferState(
        id: transferId,
        title: 'Uploading ${content.title}',
        type: TransferType.content,
        direction: TransferDirection.upload,
        progress: 0.0,
        uploadedBytes: 0,
        totalBytes: 100,
        startedAt: DateTime.now(),
        status: TransferStatus.inProgress,
        sourceKey: content.uid,
      ),
    );

    try {
      final userIdResult = await UserDataFunctions().getUserId();
      if (!userIdResult.isSuccess || userIdResult.data == null) {
        transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
        uploadFeedNotifier.fail(transferId, 'User not authenticated');
        NotificationService.instance.showCompletion(
          title: 'Upload failed',
          body: '${content.title}: not authenticated',
        );
        if (mounted) UiUtils.showFlushBar(context, msg: 'User not authenticated', vibe: FlushbarVibe.error);
        return;
      }

      final parentCollection = await ModuleRepo.getByUid(content.parentId);
      if (parentCollection == null) {
        transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
        uploadFeedNotifier.fail(transferId, 'Parent collection not found');
        NotificationService.instance.showCompletion(
          title: 'Upload failed',
          body: '${content.title}: parent collection missing',
        );
        if (mounted) UiUtils.showFlushBar(context, msg: 'Parent collection not found', vibe: FlushbarVibe.error);
        return;
      }

      final vaultResult = await Api.instance.vault.listVaults();
      if (!vaultResult.isSuccess || vaultResult.data == null || vaultResult.data!.isEmpty) {
        transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
        uploadFeedNotifier.fail(transferId, 'No vault links available');
        NotificationService.instance.showCompletion(
          title: 'Upload failed',
          body: '${content.title}: no vault links available',
        );
        if (mounted) {
          UiUtils.showFlushBar(context, msg: 'No vault links available. Contact admin.', vibe: FlushbarVibe.error);
        }
        return;
      }

      final vaultLinks = vaultResult.data!.map((vault) => vault.url).toList();

      final result = await SyncCoordinator().syncContent(
        content: content,
        courseId: parentCollection.parentId,
        collectionId: content.parentId,
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
            title: content.title,
            progress: safeTransferred,
            maxProgress: safeTotal,
          );
        },
      );

      final data = result.data;
      if (data?.success ?? false) {
        transferNotifier.updateProgress(id: transferId, progress: 1.0, uploadedBytes: 100, totalBytes: 100);
        transferNotifier.updateStatus(id: transferId, status: TransferStatus.completed);
        uploadFeedNotifier.complete(
          transferId,
          note: 'Uploaded ${data?.uploadedCount ?? 0} • Skipped ${data?.skippedCount ?? 0}',
          contentId: content.uid,
          collectionId: content.parentId,
          courseId: parentCollection.parentId,
        );
        NotificationService.instance.cancel(transferId);
        NotificationService.instance.showCompletion(
          title: 'Upload completed',
          body:
              '${content.title}: Uploaded ${data?.uploadedCount ?? 0}, Skipped ${data?.skippedCount ?? 0}, Failed ${data?.failedCount ?? 0}',
        );
        if (mounted) UiUtils.showFlushBar(context, msg: 'Upload completed', vibe: FlushbarVibe.success);
      } else {
        transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
        uploadFeedNotifier.fail(transferId, data?.error ?? 'Upload failed');
        NotificationService.instance.cancel(transferId);
        NotificationService.instance.showCompletion(
          title: 'Upload failed',
          body: '${content.title}: ${data?.error ?? 'Upload failed'}',
        );
        if (mounted) UiUtils.showFlushBar(context, msg: data?.error ?? 'Upload failed', vibe: FlushbarVibe.error);
      }
    } catch (error) {
      transferNotifier.updateStatus(id: transferId, status: TransferStatus.failed);
      uploadFeedNotifier.fail(transferId, 'Upload failed: $error');
      NotificationService.instance.cancel(transferId);
      NotificationService.instance.showCompletion(title: 'Upload failed', body: '${content.title}: $error');
      if (mounted) UiUtils.showFlushBar(context, msg: 'Upload failed: $error', vibe: FlushbarVibe.error);
    } finally {
      transferNotifier.removeTransfer(transferId);
    }
  }

  Widget _buildLeadingMenuOption(String title, {required IconData iconData, required void Function() onTap}) {
    final theme = ref;
    return Expanded(
      child: CustomElevatedButton(
        contentPadding: EdgeInsets.zero,
        pixelWidth: 100,
        pixelHeight: 60,
        onClick: onTap,
        backgroundColor: Colors.transparent,
        child: Column(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 24, color: theme.onBackground.withAlpha(200)),
            CustomText(
              title,
              fontSize: 14,
              color: theme.onBackground,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
