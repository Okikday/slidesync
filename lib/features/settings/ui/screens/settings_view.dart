import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/core/storage/hive_data/app_hive_data.dart';
import 'package:slidesync/core/storage/hive_data/hive_data_paths.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/core/utils/file_utils.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/features/settings/logic/models/settings_model.dart';
import 'package:slidesync/features/settings/providers/settings_controller.dart';
import 'package:slidesync/features/settings/ui/components/settings_appearance_dialog.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';
import 'package:slidesync/shared/widgets/app_bar/app_bar_container.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(Colors.transparent, context.isDarkMode),
      child: Scaffold(
        appBar: AppBarContainer(child: AppBarContainerChild(context.isDarkMode, title: "Settings")),

        body: Consumer(
          builder: (context, ref, child) {
            final settingsModelProvider = ref.watch(SettingsController.settingsProvider);
            final settingsModel = settingsModelProvider.value == null
                ? SettingsModel()
                : SettingsModel.fromMap(settingsModelProvider.value!);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: SmoothListView(
                children: [
                  CustomText("Appearance", color: theme.supportingText),

                  ConstantSizing.columnSpacingMedium,

                  SettingsCard(
                    title: "App Theme",
                    iconData: Iconsax.sun,
                    content: "Customize colors to suit your style",
                    trailing: CustomElevatedButton(
                      label: "Change",
                      backgroundColor: theme.altBackgroundPrimary,
                      textColor: theme.supportingText,
                      textSize: 14,
                      onClick: () {
                        CustomDialog.show(
                          context,
                          barrierColor: Colors.black26,
                          blurSigma: Offset(2, 2),
                          child: SettingsAppearanceDialog(),
                        );
                      },
                    ),
                  ),

                  ConstantSizing.columnSpacingMedium,

                  SettingsCard(
                    title: "Use system brightness",
                    iconData: Iconsax.sun_1,
                    content: "Switch theme when system brightness changes",
                    trailing: Switch(
                      value: settingsModel.useSystemBrightness,
                      onChanged: (p) async {
                        ref
                            .read(SettingsController.settingsProvider.notifier)
                            .set(
                              SettingsModel.fromMap(
                                (await ref.read(SettingsController.settingsProvider.future)),
                              ).copyWith(useSystemBrightness: p).toMap(),
                            );
                      },
                    ),
                  ),

                  // ConstantSizing.columnSpacingLarge,

                  // CustomText("Experience", color: theme.supportingText),

                  // ConstantSizing.columnSpacingMedium,

                  // SettingsCard(
                  //   title: "Summarized suggestions",
                  //   iconData: Iconsax.sun,
                  //   content: "Use your materials to suggest what to read",
                  //   trailing: Switch(value: false, onChanged: (p) {}),
                  // ),
                  ConstantSizing.columnSpacingLarge,

                  CustomText("Technical", color: theme.supportingText),

                  // ConstantSizing.columnSpacingMedium,

                  // SettingsCard(
                  //   title: "Content not copied",
                  //   iconData: Iconsax.copy,
                  //   content: "Turning this on requires storage permission and reduces storage usage.",
                  //   trailing: Switch(value: false, onChanged: (p) {}),
                  // ),
                  ConstantSizing.columnSpacingMedium,

                  SettingsCard(
                    title: "Built-in viewer",
                    iconData: Iconsax.sun,
                    content:
                        "When enabled, materials will open using the app’s built-in viewer instead of an external app.\nDoesn't apply for unsupported files.\nProgress won't be tracked if disabled*",
                    trailing: Switch(
                      value: settingsModel.useBuiltInViewer ?? !DeviceUtils.isDesktop(),
                      onChanged: (p) async {
                        log("p: $p");
                        final newValue = SettingsModel.fromMap(
                          (await ref.read(SettingsController.settingsProvider.future)),
                        ).copyWith(useBuiltInViewer: p).toMap();
                        log("prev:${settingsModel.useBuiltInViewer}");
                        log("next: ${newValue['useBuiltInViewer']}");
                        ref.read(SettingsController.settingsProvider.notifier).set(newValue);
                      },
                    ),
                  ),

                  ConstantSizing.columnSpacingMedium,

                  if (DeviceUtils.isDesktop())
                    SettingsCard(
                      title: "Show materials in full view always",
                      iconData: Iconsax.sun,
                      content: "Whether to always open a collection of materials in full screen or not",
                      trailing: Switch(
                        value: settingsModel.showMaterialsInFullScreen,
                        onChanged: (p) async {
                          ref
                              .read(SettingsController.settingsProvider.notifier)
                              .set(
                                SettingsModel.fromMap(
                                  (await ref.read(SettingsController.settingsProvider.future)),
                                ).copyWith(showMaterialsInFullScreen: p).toMap(),
                              );
                        },
                      ),
                    ),

                  ConstantSizing.columnSpacingMedium,

                  // SettingsCard(
                  //   title: "Repair",
                  //   iconData: Icons.fire_extinguisher,
                  //   content: "Attempts to fix any anomaly",
                  // ),

                  // ConstantSizing.columnSpacingMedium,

                  // SettingsCard(
                  //   title: "Allow opening multiple contents (Experimental)",
                  //   iconData: Icons.view_agenda,
                  //   content: "Allows to view more than one content by overlaying the others maxing out at 3",
                  // ),
                  SettingsCard(
                    title: "Clear App's cache",
                    iconData: Icons.view_agenda,
                    content: "This can help free up device space by clearing temporary files.",
                    trailing: CustomElevatedButton(
                      label: "Clear",
                      backgroundColor: theme.altBackgroundPrimary,
                      textColor: theme.supportingText,
                      textSize: 14,
                      onClick: () async {
                        final token = RootIsolateToken.instance;
                        if (token != null) {
                          await compute(FileUtils.deleteEmptyCoursesDirsInIsolate, {'rootIsolateToken': token});
                          await FileUtils().clearCacheOrTemp();
                          await AppHiveData.instance.setData(
                            key: HiveDataPathKey.lastClearedCacheDate.name,
                            value: DateTime.now(),
                          );
                          GlobalNav.withContext(
                            (context) =>
                                UiUtils.showFlushBar(context, msg: "Successfully cleared up temporary files.."),
                          );
                        }
                      },
                    ),
                  ),

                  ConstantSizing.columnSpacingMedium,

                  // SettingsCard(
                  //   title: "Backup contents organization",
                  //   iconData: Icons.view_agenda,
                  //   content: "This backs up how your files are arranged without uploading your files.",
                  //   trailing: CustomElevatedButton(
                  //     label: "Backup",
                  //     backgroundColor: theme.altBackgroundPrimary,
                  //     textColor: theme.supportingText,
                  //     textSize: 14,
                  //     onClick: () async {
                  //       UiUtils.showLoadingDialog(context, canPop: false);
                  //       // await FirebaseCourseService().uploadBackup(
                  //       //   courses: await CourseRepo.getAllCourses(),
                  //       //   collections: await CourseCollectionRepo.getAll(),
                  //       //   contents: await CourseContentRepo.getAll(),
                  //       // );
                  //       GlobalNav.popGlobal();
                  //     },
                  //   ),
                  // ),

                  // ConstantSizing.columnSpacingMedium,
                  Center(
                    child: FutureBuilder(
                      future: AppHiveData.instance.getData(key: HiveDataPathKey.globalFileSizeSum.name),
                      builder: (context, asyncSnapshot) {
                        if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
                          final mb =
                              Result.tryRun(() => ((asyncSnapshot.data as int?) ?? 0) / (1024 * 1024)).data ?? 0.0;
                          return CustomText("Storage usage: ${mb.toStringAsFixed(2)} MB", color: theme.supportingText);
                        }
                        return CustomText("Storage usage details unavailable", color: theme.supportingText);
                      },
                    ),
                  ),

                  // Help: Note, Materials won't be uploaded except you explicitly share them.
                  // Option: Always show download size before downloading from SlideSync Repo

                  // ConstantSizing.columnSpacingMedium,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SettingsCard extends ConsumerWidget {
  final String title;
  final IconData iconData;
  final String? content;
  final Widget? trailing;
  const SettingsCard({super.key, required this.title, required this.iconData, this.content, this.trailing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return Tooltip(
      textAlign: TextAlign.left,
      showDuration: 4.inSeconds,
      richMessage: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: context.theme.tooltipTheme.textStyle?.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: "\n\n$content", style: context.theme.tooltipTheme.textStyle?.copyWith(fontSize: 13)),
        ],
      ),
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(color: theme.supportingText.withAlpha(10), borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(iconData),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Flexible(
                      child: CustomText(title, color: theme.onBackground, overflow: TextOverflow.ellipsis),
                    ),
                    if (content != null)
                      Flexible(
                        child: CustomText(
                          content!,
                          fontSize: 11,
                          color: theme.supportingText,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
