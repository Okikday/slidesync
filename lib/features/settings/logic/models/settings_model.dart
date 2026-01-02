import 'package:slidesync/core/utils/device_utils.dart';

class SettingsModel {
  /// Whether to automatically switch theme based on system brightness
  bool useSystemBrightness;

  /// Whether content copying is disabled (requires storage permission)
  bool contentNotCopied;

  /// Whether to use the app’s built-in viewer instead of external apps
  bool? useBuiltInViewer;

  /// Whether the app should provide summarized reading suggestions
  bool summarizedSuggestions;

  /// Allows multiple contents to open simultaneously (experimental feature)
  bool allowMultipleContents;

  bool showMaterialsInFullScreen;

  SettingsModel({
    this.useSystemBrightness = true,
    this.contentNotCopied = false,
    // this.useBuiltInViewer = true,
    this.useBuiltInViewer,
    this.summarizedSuggestions = false,
    this.allowMultipleContents = false,
    this.showMaterialsInFullScreen = false,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      useSystemBrightness: map['useSystemBrightness'] ?? false,
      contentNotCopied: map['contentNotCopied'] ?? false,
      useBuiltInViewer: map['useBuiltInViewer'] ?? true,
      summarizedSuggestions: map['summarizedSuggestions'] ?? false,
      allowMultipleContents: map['allowMultipleContents'] ?? false,
      showMaterialsInFullScreen: map['showMaterialsInFullScreen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'useSystemBrightness': useSystemBrightness,
      'contentNotCopied': contentNotCopied,
      'useBuiltInViewer': useBuiltInViewer,
      'summarizedSuggestions': summarizedSuggestions,
      'allowMultipleContents': allowMultipleContents,
      'showMaterialsInFullScreen': showMaterialsInFullScreen,
    };
  }
}

extension SettingsModelExtension on SettingsModel {
  SettingsModel copyWith({
    bool? useSystemBrightness,
    bool? contentNotCopied,
    bool? useBuiltInViewer,
    bool? summarizedSuggestions,
    bool? allowMultipleContents,
    bool? showMaterialsInFullScreen,
  }) {
    return SettingsModel(
      useSystemBrightness: useSystemBrightness ?? this.useSystemBrightness,
      contentNotCopied: contentNotCopied ?? this.contentNotCopied,
      useBuiltInViewer: useBuiltInViewer ?? this.useBuiltInViewer,
      summarizedSuggestions: summarizedSuggestions ?? this.summarizedSuggestions,
      allowMultipleContents: allowMultipleContents ?? this.allowMultipleContents,
      showMaterialsInFullScreen: showMaterialsInFullScreen ?? this.showMaterialsInFullScreen,
    );
  }
}
