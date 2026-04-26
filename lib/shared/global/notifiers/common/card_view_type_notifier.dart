import 'package:slidesync/core/constants/src/enums/enums.dart';
import 'package:slidesync/shared/global/notifiers/primitive_type_notifiers.dart';

class CardViewTypeNotifier extends HiveAsyncImpliedNotifier<String, CardViewType> {
  CardViewTypeNotifier(super.hiveKey, super.defaultValue)
    : super(
        builder: (data) => CardViewType.values.where((t) => t.name == data).firstOrNull ?? defaultValue,
        transformer: (type) => type.name,
      );
}
