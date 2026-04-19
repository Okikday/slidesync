import 'package:flutter/widgets.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/constants/src/enums.dart';

class WidgetHelper {
  static IconData resolveIconData(CourseContentType type, [bool isOutlined = false]) {
    switch (type) {
      // case CourseContentType.audio:
      //   return isOutlined ? Iconsax.audio_square_copy : Iconsax.audio_square;
      case CourseContentType.document:
        return isOutlined ? HugeIconsStroke.documentAttachment : HugeIconsSolid.documentAttachment;
      case CourseContentType.image:
        return isOutlined ? HugeIconsStroke.image01 : HugeIconsSolid.image01;
      case CourseContentType.link:
        return isOutlined ? HugeIconsStroke.link03 : HugeIconsSolid.link03;
      case CourseContentType.unknown:
        return isOutlined ? HugeIconsStroke.fileUnknown : HugeIconsSolid.fileUnknown;
      // case CourseContentType.video:
      //   return isOutlined ? Iconsax.video_copy : Iconsax.video;
      case CourseContentType.note:
        return isOutlined ? HugeIconsStroke.note : HugeIconsSolid.note;
      case CourseContentType.reference:
        return isOutlined ? HugeIconsStroke.folderDetailsReference : HugeIconsSolid.folderDetailsReference;
      default:
        return HugeIconsSolid.fileUnknown;
    }
  }
}
