import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/manage/presentation/contents/controllers/src/modify_contents_controller.dart';
import 'package:slidesync/features/manage/presentation/contents/views/modify_contents/mod_content_card_tile.dart';
import 'package:slidesync/shared/global/providers/collections_providers.dart';
import 'package:slidesync/shared/widgets/progress_indicator/loading_logo.dart';

class ModifyContentListView extends ConsumerWidget {
  final String collectionId;
  const ModifyContentListView({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mcvp = ref.watch(ModifyContentsController.modifyContentsStateProvider);
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: Consumer(
        builder: (context, ref, child) {
          final links = ref.watch(
            CollectionsProviders.collectionProvider(collectionId).select((c) => c.whenData((cb) => cb.contents)),
          );
          return links.when(
            data: (data) {
              final contents = data.toList();
              return SliverList.builder(
                itemCount: contents.length,
                itemBuilder: (context, index) {
                  final content = contents[index];
                  return ValueListenableBuilder(
                    valueListenable: mcvp.selectedContentsNotifier,

                    builder: (context, value, child) {
                      final lookUp = value.lookup(content);
                      return ModContentCardTile(
                        content: content,
                        isSelected: value.isEmpty ? null : (value.isNotEmpty && lookUp != null ? true : false),
                        onTap: () {
                          if (value.isNotEmpty) {
                            final check = value.lookup(content);
                            if (check != null) {
                              mcvp.removeContent(content);
                            } else {
                              mcvp.selectContent(content);
                            }
                          } else {
                            // Normal action
                          }
                        },
                        onSelected: () {
                          final check = value.lookup(content);
                          if (check != null) {
                            mcvp.removeContent(content);
                          } else {
                            mcvp.selectContent(content);
                          }
                        },
                      ).animate().fadeIn().slideY(
                        begin: (index / contents.length + 1) * 0.4,
                        end: 0,
                        curve: Curves.fastEaseInToSlowEaseOut,
                        duration: Durations.extralong2,
                      );
                    },
                  );
                },
              );
            },
            error: (_, _) => const SliverToBoxAdapter(child: Icon(Icons.error)),
            loading: () => const SliverToBoxAdapter(child: LoadingLogo()),
          );
        },
      ),
    );
  }
}
