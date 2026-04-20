import 'dart:developer';

import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/utils/device_utils.dart';
import 'package:slidesync/features/settings/providers/settings_provider.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/theme/src/built_in_themes.dart';
import 'package:slidesync/shared/theme/theme.dart';
import 'package:slidesync/shared/widgets/dialogs/app_customizable_dialog.dart';
import 'package:slidesync/shared/widgets/state/absorber.dart';

class SettingsAppearanceDialog extends ConsumerStatefulWidget {
  const SettingsAppearanceDialog({super.key});

  @override
  ConsumerState<SettingsAppearanceDialog> createState() => _SettingsAppearanceDialogState();
}

class _SettingsAppearanceDialogState extends ConsumerState<SettingsAppearanceDialog> {
  List<ThemePair> _buildPairsFromUnified(List<UnifiedThemeModel> models) {
    return models.map((unified) => ThemePair.fromUnified(unified)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pairs = _buildPairsFromUnified(defaultUnifiedThemeModels);
    final isNotAdaptiveDarkTheme = ref.brightness == Brightness.dark;

    return AppCustomizableDialog(
      blurSigma: const Offset(2, 2),
      leading: Center(child: CustomText("Adjust Theme", color: ref.onSurface)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: AbsorberWatch(
            listenable: SettingsProvider.settingsProvider.select((s) => s.whenData((cb) => cb.useSystemBrightness)),
            builder: (context, usb, ref, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstantSizing.columnSpacingMedium,

                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          return usb.when(
                            data: (data) {
                              if (data) return const SizedBox();
                              return ToggleButtons(
                                isSelected: [!isNotAdaptiveDarkTheme, isNotAdaptiveDarkTheme],
                                onPressed: (index) {
                                  if (data) return;
                                  final curr = ref.read(appThemeProvider);
                                  ref
                                      .read(appThemeProvider.notifier)
                                      .set(
                                        curr.copyWith(
                                          currentBrightness: index == 0 ? Brightness.light : Brightness.dark,
                                        ),
                                      );
                                },
                                borderRadius: BorderRadius.circular(8),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text('Light'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Text('Dark'),
                                  ),
                                ],
                              );
                            },
                            error: (e, st) => Icon(Icons.error),
                            loading: () => const SizedBox.square(dimension: 40),
                          );
                        },
                      ),
                    ],
                  ),

                  ConstantSizing.columnSpacingSmall,

                  Builder(
                    builder: (context) {
                      return usb.when(
                        data: (data) {
                          return ThemePairPicker(
                            pairs: pairs,
                            forceBrightness: data ? null : (context.mediaQuery.platformBrightness),
                            crossAxisCount: DeviceUtils.isDesktop() ? ((context.deviceWidth ~/ 200).clamp(1, 100)) : 2,
                            spacing: 12,
                            onSelected: (pair, chosen) {
                              final curr = ref.read(appThemeProvider);
                              ref.read(appThemeProvider.notifier).set(curr.copyWith(currentBrightness: chosen));
                            },
                          );
                        },
                        error: (e, st) => Icon(Icons.error),
                        loading: () => const SizedBox.square(dimension: 40),
                      );
                    },
                  ),

                  ConstantSizing.columnSpacingMedium,
                ],
              );
            },
          ),
        ),
      ),
    ).animate().flipV(duration: Durations.medium1, curve: CustomCurves.defaultIosSpring);
  }
}

class ThemePair {
  final String id;
  final String title;
  final UnifiedThemeModel unifiedModel;
  final AppTheme lightModel;
  final AppTheme darkModel;

  ThemePair({
    required this.id,
    required this.title,
    required this.unifiedModel,
    required this.lightModel,
    required this.darkModel,
  });

  factory ThemePair.fromUnified(UnifiedThemeModel unified) {
    return ThemePair(
      id: unified.title,
      title: unified.title,
      unifiedModel: unified,
      lightModel: unified.theme,
      darkModel: unified.darkTheme,
    );
  }
}

class ThemePairPicker extends ConsumerWidget {
  final List<ThemePair> pairs;
  final Brightness? forceBrightness;
  final void Function(ThemePair pair, Brightness chosen)? onSelected;
  final int crossAxisCount;
  final double spacing;

  const ThemePairPicker({
    super.key,
    required this.pairs,
    this.forceBrightness,
    this.onSelected,
    this.crossAxisCount = 2,
    this.spacing = 12.0,
  });

  Future<void> _applyPair(BuildContext context, WidgetRef ref, ThemePair pair, Brightness chosen) async {
    try {
      ref.read(appThemeProvider.notifier).set(pair.unifiedModel.copyWith(currentBrightness: chosen));
    } catch (_) {
      log('Failed to update theme provider');
    }

    if (onSelected != null) onSelected!(pair, chosen);
  }

  Widget _buildSwatchPair(BuildContext context, ThemePair pair) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 200, maxWidth: 250),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [pair.lightModel.primary, pair.lightModel.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: pair.lightModel.primary.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'L',
                  style: TextStyle(color: pair.lightModel.onPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [pair.darkModel.primary, pair.darkModel.secondary],
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Text(
                  'D',
                  style: TextStyle(color: pair.darkModel.onPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeProvider);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pairs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final pair = pairs[index];
        final isSelected = currentTheme.title == pair.title;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 300, maxWidth: 350),
          child: GestureDetector(
            onTap: () async {
              await _applyPair(context, ref, pair, currentTheme.currentBrightness);
            },
            child: Material(
              color: currentTheme.currentTheme.surface,
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: isSelected ? 4 : 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected ? Border.all(color: currentTheme.currentTheme.primary, width: 2.5) : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Expanded(child: _buildSwatchPair(context, pair)),
                      const SizedBox(height: 8),
                      Text(
                        pair.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? currentTheme.currentTheme.primary : currentTheme.currentTheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.circle, size: 10, color: pair.lightModel.primary),
                          const SizedBox(width: 6),
                          Icon(Icons.circle, size: 10, color: pair.darkModel.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
