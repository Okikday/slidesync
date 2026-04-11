import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/ask_ai/providers/src/ask_ai_screen_state.dart';
import 'package:slidesync/features/auth/logic/usecases/auth_uc/user_data_functions.dart';

class AskAiScreenProvider {
  ///|
  ///|
  /// ===================================================================================================
  /// STATE
  /// ===================================================================================================
  static final state = NotifierProvider<AskAiScreenNotifier, AskAiViewState>(
    AskAiScreenNotifier.new,
    isAutoDispose: true,
  );

  static final notifier = state.notifier;

  ///|
  ///|
  /// ===================================================================================================
  /// OTHERS
  /// ===================================================================================================
  static final userIdProvider = FutureProvider<String>((ref) async {
    return (await UserDataFunctions().getUserDetails()).data?.userID ?? '';
  });
}
