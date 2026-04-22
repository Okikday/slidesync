import 'package:flutter/widgets.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/core/constants/src/enums.dart';

class WidgetHelper {
  static IconData resolveIconData(ModuleContentType type, [bool isOutlined = false]) {
    switch (type) {
      // case CourseContentType.audio:
      //   return isOutlined ? Iconsax.audio_square_copy : Iconsax.audio_square;
      case ModuleContentType.document:
        return isOutlined ? HugeIconsStroke.documentAttachment : HugeIconsSolid.documentAttachment;
      case ModuleContentType.image:
        return isOutlined ? HugeIconsStroke.image01 : HugeIconsSolid.image01;
      case ModuleContentType.link:
        return isOutlined ? HugeIconsStroke.link03 : HugeIconsSolid.link03;
      case ModuleContentType.unknown:
        return isOutlined ? HugeIconsStroke.fileUnknown : HugeIconsSolid.fileUnknown;
      // case CourseContentType.video:
      //   return isOutlined ? Iconsax.video_copy : Iconsax.video;
      case ModuleContentType.note:
        return isOutlined ? HugeIconsStroke.note : HugeIconsSolid.note;
      case ModuleContentType.reference:
        return isOutlined ? HugeIconsStroke.folderDetailsReference : HugeIconsSolid.folderDetailsReference;
      default:
        return HugeIconsSolid.fileUnknown;
    }
  }
}
