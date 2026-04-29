import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slidesync/core/utils/result.dart';
import 'package:slidesync/core/utils/ui_utils.dart';
import 'package:slidesync/data/models/course/course.dart';
import 'package:slidesync/data/models/module/module.dart';
import 'package:slidesync/data/repos/course_repo/module_repo.dart';
import 'package:slidesync/data/repos/course_repo/course_repo.dart';
import 'package:slidesync/routes/app_router.dart';
import 'package:slidesync/features/browse/logic/src/collections/modify_collection_uc.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class ModifyModuleActions {
  /// Add collection to course
  Future<String?> _addCollectionToCourse(String courseId, String title) async {
    final Course? course = await CourseRepo.getCourseByUid(courseId);
    if (course == null) {
      return "Couldn't find course!";
    }
    await course.modules.load();
    if (course.modules.length >= 30) {
      return "Collections under a course must be under 30";
    }
    final newCollection = Module.create(parentId: course.uid, title: title);
    final String? result = await ModuleRepo.addCollectionNoDuplicateTitle(newCollection);
    return result;
  }

  Future<String?> validateCollectionTitle(
    BuildContext context, {
    required String text,
    required String collectionTitle,
  }) async {
    void showMessage(String message) =>
        UiUtils.showFlushBar(context, msg: message, flushbarPosition: FlushbarPosition.TOP, vibe: FlushbarVibe.warning);
    final String message;
    if (text.trim().isEmpty) {
      message = "Try typing into the Field!";
      showMessage(message);
      return message;
    } else if (text.length < 2) {
      message = "Text input is too short!";
      showMessage(message);
      return message;
    } else if (text.trim() == collectionTitle) {
      message = "Try inputting a new different title";
      showMessage(message);
      return message;
    } else {
      return null;
    }
  }

  Future<String?> onCreateNewCollection(BuildContext context, {required String text, required String courseId}) async {
    if (text.isNotEmpty && text.length > 1 && text.length < 256) {
      final Result<String?> createOutcome = await Result.tryRunAsync<String?>(
        () async => await _addCollectionToCourse(courseId, text),
      );

      if (createOutcome.isSuccess && createOutcome.data == null) {
        return null;
      } else if (createOutcome.isSuccess) {
        return createOutcome.data;
      } else {
        log("${createOutcome.message}");
        return 'An error occured while adding to collections';
      }
    }
    return '';
  }

  Future<String?> renameCollectionAction(Module collection) async {
    final Result<String?> renameOutcome = await Result.tryRunAsync<String?>(() async {
      final String? result = await ModuleRepo.addCollectionNoDuplicateTitle(collection);
      return (result == null ? result : "An error occured while renaming collection!");
    });
    if (renameOutcome.isSuccess && renameOutcome.data == null) {
      return null;
    } else if (renameOutcome.isSuccess) {
      return renameOutcome.data;
    } else {
      log("${renameOutcome.message}");
      return "An error occured whilst renaming collection!";
    }
  }

  Future<Course?> pickMoveTargetCourse(BuildContext context, {required String excludeCourseId}) async {
    final courses = await CourseRepo.getAllCourses();
    if (!context.mounted || courses.isEmpty) return null;

    final availableCourses = courses.where((course) => course.uid != excludeCourseId).toList();
    if (availableCourses.isEmpty) return null;

    return await showModalBottomSheet<Course>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText('Move collection to', fontSize: 18, fontWeight: FontWeight.w700),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: availableCourses.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final course = availableCourses[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        tileColor: Theme.of(sheetContext).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                        title: CustomText(course.title, fontWeight: FontWeight.w600),
                        subtitle: CustomText(course.description, fontSize: 12),
                        onTap: () => Navigator.of(sheetContext).pop(course),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onRenameCollection(BuildContext context, {required String newText, required Module collection}) async {
    if (newText.isNotEmpty && newText != collection.title && newText.length >= 2 && newText.length < 256) {
      final String? outcome = await renameCollectionAction(collection.copyWith(title: newText));
      if (context.mounted) CustomDialog.hide(context);
      if (context.mounted) {
        if (outcome == null) {
          await UiUtils.showFlushBar(
            context,
            msg: "Successfully renamed collection to $newText",
            vibe: FlushbarVibe.success,
          );
        } else {
          await UiUtils.showFlushBar(context, msg: outcome, vibe: FlushbarVibe.warning);
        }
        return;
      }
    } else {
      CustomDialog.hide(context);
    }
  }

  Future<void> onDeleteCollection(BuildContext context, {required Module collection}) async {
    GlobalNav.popGlobal();
    final BuildContext? newContext = rootNavigatorKey.currentContext;

    if (newContext != null) {
      UiUtils.showLoadingDialog(
        newContext,
        canPop: true,
        message: "Deleting collection",
        barrierColor: Colors.black.withValues(alpha: 0.6),
        backgroundColor: Colors.red.withAlpha(20),
        blurSigma: Offset(2, 2),
      );

      final Result<String?> deleteOutcome = await Result.tryRunAsync(
        () => ModifyCollectionUc().deleteCollection(collection),
      );
      rootNavigatorKey.currentContext?.pop();
      if (deleteOutcome.isSuccess && deleteOutcome.data == null) {
        if (newContext.mounted) {
          await UiUtils.showFlushBar(
            newContext,
            msg: "Successfully removed ${collection.title}",
            vibe: FlushbarVibe.success,
          );
        }
      } else {
        log("${deleteOutcome.message}");
        if (newContext.mounted) {
          await UiUtils.showFlushBar(newContext, msg: "Error deleting collection", vibe: FlushbarVibe.error);
        }
      }
    }
  }
}
