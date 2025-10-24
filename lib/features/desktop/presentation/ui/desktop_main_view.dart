// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/features/desktop/presentation/ui/views/desktop_explore_view.dart';
// import 'package:slidesync/features/desktop/presentation/ui/views/desktop_home_view.dart';
// import 'package:slidesync/features/desktop/presentation/ui/views/desktop_library_view.dart';
// import 'package:slidesync/features/desktop/presentation/ui/widgets/desktop_nav_rail.dart';
// import 'package:slidesync/features/main/presentation/home/ui/home_tab_view/src/home_drawer.dart';
// import 'package:slidesync/features/main/presentation/main/logic/main_provider.dart';

// /// The main view for the desktop layout.
// /// It consists of a permanent navigation rail on the left and a page view for the main content.
// class DesktopMainView extends ConsumerStatefulWidget {
//   final int tabIndex;
//   const DesktopMainView({super.key, required this.tabIndex});

//   @override
//   ConsumerState<DesktopMainView> createState() => _DesktopMainViewState();
// }

// class _DesktopMainViewState extends ConsumerState<DesktopMainView> {
//   late final PageController pageController;

//   @override
//   void initState() {
//     super.initState();
//     pageController = PageController(initialPage: widget.tabIndex);
//     // Set the initial tab index in the provider after the first frame.
//     WidgetsBinding.instance.addPostFrameCallback(
//       (_) => ref.read(MainProvider.tabIndexProvider.notifier).state = widget.tabIndex,
//     );
//   }

//   @override
//   void dispose() {
//     pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tabIndex = ref.watch(MainProvider.tabIndexProvider);

//     return Scaffold(
//       // The drawer is still available and can be opened from the nav rail.
//       drawer: const HomeDrawer(),
//       body: Row(
//         children: [
//           // 1. The persistent Navigation Rail on the left.
//           DesktopNavRail(
//             selectedIndex: tabIndex,
//             onDestinationSelected: (index) {
//               if (index != tabIndex) {
//                 ref.read(MainProvider.tabIndexProvider.notifier).state = index;
//                 // Jump to the corresponding page in the PageView.
//                 pageController.jumpToPage(index);
//               }
//             },
//           ),
//           const VerticalDivider(thickness: 1, width: 1),
//           // 2. The main content area, which is an Expanded PageView.
//           Expanded(
//             child: PageView(
//               controller: pageController,
//               // Disable swiping between pages, navigation is handled by the rail.
//               physics: const NeverScrollableScrollPhysics(),
//               children: const [
//                 DesktopHomeView(),
//                 DesktopLibraryView(),
//                 DesktopExploreView(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
