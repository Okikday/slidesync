import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/ask_ai/providers/src/ask_ai_screen_state.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';

class AskAiScreenProvider {
  ///|
  ///|
  /// ===================================================================================================
  /// STATE
  /// ===================================================================================================
  static final state = Provider.autoDispose<AskAiScreenState>((ref) {
    final aass = AskAiScreenState(ref);
    ref.onDispose(aass.dispose);
    return aass;
  });

  ///|
  ///|
  /// ===================================================================================================
  /// OTHERS
  /// ===================================================================================================
  static final userIdProvider = FutureProvider<String>((ref) async {
    return (await UserDataFunctions().getUserDetails()).data?.userID ?? '';
  });
}
