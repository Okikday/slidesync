import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:slidesync/features/main/ui/widgets/library_tab_view/src/library_tab_view_app_bar/build_button.dart';
import 'package:slidesync/routes/routes.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/widgets/layout/app_padding.dart';
import 'package:slidesync/shared/widgets/layout/smooth_list_view.dart';

class ExploreTabView extends ConsumerWidget {
  const ExploreTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref;
    return TopPadding(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SmoothCustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: CustomText("Explore", fontSize: 24, color: theme.onBackground, fontWeight: FontWeight.bold),
                  ),
                  BuildButton(
                    onTap: () {
                      context.pushNamed(Routes.sync.name);
                    },
                    iconData: Iconsax.settings,
                    backgroundColor: theme.onBackground.withAlpha(20),
                  ),
                ],
              ),
            ),

            SliverToBoxAdapter(child: ConstantSizing.columnSpacingMedium),

            SliverToBoxAdapter(
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: CustomTextfield(
                      hint: "Search something...",
                      autoDispose: false,
                      hintStyle: TextStyle(color: theme.supportingText),
                      selectionHandleColor: theme.primaryColor,
                      // inputTextStyle: TextStyle(fontSize: 15, color: theme.onBackground),
                      // backgroundColor: theme.surface,
                      // border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.zero),
                      inputContentPadding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                      inputTextStyle: TextStyle(fontSize: 15, color: theme.onBackground),
                      cursorColor: theme.primaryColor,
                      backgroundColor: Colors.transparent,
                      border: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor, width: 1.5)),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 10.0, top: 12.0, bottom: 12.0),
                        child: Icon(Iconsax.search_normal_copy, size: 20, color: theme.supportingText),
                      ),
                      onchanged: (text) {},
                    ),
                  ),

                  // BuildButton(onTap: () {}, iconData: Iconsax.filter),
                ],
              ),
            ),

            SliverToBoxAdapter(child: ConstantSizing.columnSpacingLarge),
          ],
        ),
      ),
    );
  }
}
