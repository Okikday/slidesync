import 'package:flutter/material.dart';
import 'package:slidesync/core/utils/ui_utils.dart';

class EditCollectionActions {
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
}
