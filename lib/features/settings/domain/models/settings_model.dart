class SettingsModel {
  /// Whether to automatically switch theme based on system brightness
  bool useSystemBrightness;

  /// Whether content copying is disabled (requires storage permission)
  bool contentNotCopied;

  /// Whether to use the app’s built-in viewer instead of external apps
  bool useBuiltInViewer;

  /// Whether the app should provide summarized reading suggestions
  bool summarizedSuggestions;

  /// Allows multiple contents to open simultaneously (experimental feature)
  bool allowMultipleContents;

  SettingsModel({
    this.useSystemBrightness = true,
    this.contentNotCopied = false,
    this.useBuiltInViewer = false,
    this.summarizedSuggestions = false,
    this.allowMultipleContents = false,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      useSystemBrightness: map['useSystemBrightness'] ?? false,
      contentNotCopied: map['contentNotCopied'] ?? false,
      useBuiltInViewer: map['useBuiltInViewer'] ?? false,
      summarizedSuggestions: map['summarizedSuggestions'] ?? false,
      allowMultipleContents: map['allowMultipleContents'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'useSystemBrightness': useSystemBrightness,
      'contentNotCopied': contentNotCopied,
      'useBuiltInViewer': useBuiltInViewer,
      'summarizedSuggestions': summarizedSuggestions,
      'allowMultipleContents': allowMultipleContents,
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
  }) {
    return SettingsModel(
      useSystemBrightness: useSystemBrightness ?? this.useSystemBrightness,
      contentNotCopied: contentNotCopied ?? this.contentNotCopied,
      useBuiltInViewer: useBuiltInViewer ?? this.useBuiltInViewer,
      summarizedSuggestions: summarizedSuggestions ?? this.summarizedSuggestions,
      allowMultipleContents: allowMultipleContents ?? this.allowMultipleContents,
    );
  }
}
