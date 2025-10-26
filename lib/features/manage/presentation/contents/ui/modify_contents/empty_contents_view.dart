import 'package:custom_widgets_toolkit/custom_widgets_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:slidesync/core/assets/assets.dart';
import 'package:slidesync/data/repos/course_repo/course_collection_repo.dart';
import 'package:slidesync/features/manage/presentation/contents/ui/add_contents/add_contents_bottom_sheet.dart';
import 'package:slidesync/shared/helpers/extensions/extensions.dart';
import 'package:slidesync/shared/helpers/global_nav.dart';

class EmptyContentsView extends ConsumerWidget {
  final String collectionId;
  const EmptyContentsView({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ConstantSizing.columnSpacing(context.deviceHeight * 0.2),
            SizedBox.square(dimension: 200, child: LottieBuilder.asset(Assets.icons.roundedPlayingFace, reverse: true)),

            ConstantSizing.columnSpacingExtraLarge,
            Center(
              child: CustomText(
                "We couldn't find any material over here..",
                fontSize: 12,
                color: ref.backgroundSupportingText,
              ),
            ),
            ConstantSizing.columnSpacingMedium,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomElevatedButton(
                onClick: () async {
                  if (collectionId.isEmpty) return;
                  final collection = await CourseCollectionRepo.getById(collectionId);
                  if (collection == null) return;
                  GlobalNav.withContext(
                    (context) => CustomDialog.show(
                      context,
                      transitionDuration: Durations.short1,
                      reverseTransitionDuration: Durations.short1,
                      barrierColor: Colors.black45,
                      child: AddContentsBottomSheet(collection: collection),
                    ),
                  );
                },
                backgroundColor: ref.primaryColor,
                // backgroundColor: ref.secondary,
                borderRadius: 12,
                pixelHeight: 44,
                label: "Add a content",
                textSize: 15,
                textColor: ref.onPrimary,
              ),
            ),

            // ConstantSizing.columnSpacingMedium,

            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 20.0),
            //   child: CustomElevatedButton(
            //     backgroundColor: ref.primaryColor,
            //     borderRadius: 12,
            //     pixelHeight: 44,
            //     label: "Explore Contents",
            //     textSize: 15,
            //     textColor: Colors.white,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
