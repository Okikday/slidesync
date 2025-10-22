// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/data/models/course_model/course.dart';
// import 'package:slidesync/data/models/course_model/course_content.dart';

// /// Defines the possible states for the main detail pane.
// /// It can be empty, show the dashboard, recents, a specific course, or a specific piece of content.
// sealed class DetailPaneState {
//   const DetailPaneState();
// }

// class DetailPaneEmpty extends DetailPaneState {
//   const DetailPaneEmpty();
// }

// class DetailPaneDashboard extends DetailPaneState {
//   const DetailPaneDashboard();
// }

// class DetailPaneRecents extends DetailPaneState {
//   const DetailPaneRecents();
// }

// class DetailPaneCourse extends DetailPaneState {
//   final Course course;
//   const DetailPaneCourse(this.course);
// }

// class DetailPaneContent extends DetailPaneState {
//   final CourseContent content;
//   const DetailPaneContent(this.content);
// }

// /// This provider manages the state of the "Detail Pane" (the largest content area).
// /// It determines what is currently being shown.
// final detailPaneProvider = StateProvider<DetailPaneState>((ref) {
//   // By default, show the dashboard when the app starts.
//   return const DetailPaneDashboard();
// });

// /// This provider manages the state of the "AI Panel".
// /// It's a simple boolean to toggle its visibility.
// final aiPanelProvider = StateProvider<bool>((ref) => false);
// ```eof
// ```dart:Desktop Shell View:lib/features/desktop/presentation/shell/desktop_shell_view.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/features/desktop/presentation/overlays/desktop_ai_panel.dart';
// import 'package:slidesync/features/desktop/presentation/shell/desktop_detail_pane.dart';
// import 'package:slidesync/features/desktop/presentation/shell/desktop_master_pane.dart';
// import 'package:slidesync/features/desktop/presentation/shell/desktop_nav_rail.dart';

// /// The root widget for the entire desktop UI.
// /// It builds the 3-pane layout and integrates the AI panel as an overlay.
// class DesktopShellView extends ConsumerWidget {
//   const DesktopShellView({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return const Scaffold(
//       body: Stack(
//         children: [
//           Row(
//             children: [
//               // Pane 1: Top-level navigation
//               DesktopNavRail(),
//               VerticalDivider(width: 1, thickness: 1),
              
//               // Pane 2: List view (e.g., list of courses)
//               DesktopMasterPane(),
//               VerticalDivider(width: 1, thickness: 1),
              
//               // Pane 3: Main content view (e.g., course details or PDF viewer)
//               Expanded(
//                 child: DesktopDetailPane(),
//               ),
//             ],
//           ),
          
//           // Overlay: The "Ask AI" panel that slides in from the right
//           DesktopAiPanel(),
//         ],
//       ),
//     );
//   }
// }
// ```eof
// ```dart:Desktop Navigation Rail:lib/features/desktop/presentation/shell/desktop_nav_rail.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:slidesync/features/desktop/presentation/providers/desktop_shell_provider.dart';
// import 'package:slidesync/features/main/presentation/main/logic/main_provider.dart';
// import 'package:slidesync/features/settings/presentation/views/settings_view.dart';
// import 'package:slidesync/shared/helpers/extensions/extensions.dart';
// import 'package:slidesync/shared/helpers/global_nav.dart';
// import 'package:slidesync/shared/widgets/dialogs/app_customizable_dialog.dart';

// /// Pane 1: The far-left navigation rail.
// /// Replaces the mobile BottomNavBar and integrates profile/settings.
// class DesktopNavRail extends ConsumerWidget {
//   const DesktopNavRail({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.theme;
//     final tabIndex = ref.watch(MainProvider.tabIndexProvider);

//     void showSettingsModal() {
//       AppCustomizableDialog.show(
//         context,
//         child: const SettingsView(),
//         maxWidth: 600,
//       );
//     }

//     void showProfileModal() {
//       // Reusing the HomeDrawer content, but in a dialog for desktop
//       AppCustomizableDialog.show(
//         context,
//         child: const Drawer(
//           // TODO: You'll want to create a dedicated ProfileView widget
//           // and use it here instead of the mobile HomeDrawer.
//           // For now, this demonstrates reuse.
//           child: Text("Profile/Settings Drawer Content"),
//         ),
//         maxWidth: 400,
//         alignment: Alignment.topLeft,
//         padding: EdgeInsets.zero,
//       );
//     }

//     return NavigationRail(
//       selectedIndex: tabIndex,
//       backgroundColor: theme.background.withOpacity(0.5),
//       indicatorColor: theme.primaryColor.withOpacity(0.1),
//       selectedIconTheme: IconThemeData(color: theme.primaryColor),
//       unselectedIconTheme: IconThemeData(color: theme.onBackground.withOpacity(0.6)),
//       labelType: NavigationRailLabelType.all,
//       onDestinationSelected: (index) {
//         ref.read(MainProvider.tabIndexProvider.notifier).state = index;

//         // When navigation changes, reset the detail pane
//         final notifier = ref.read(detailPaneProvider.notifier);
//         switch (index) {
//           case 0:
//             notifier.state = const DetailPaneDashboard(); // Default to Dashboard
//           case 1:
//             notifier.state = const DetailPaneEmpty(); // Show "Select a course"
//           case 2:
//             notifier.state = const DetailPaneEmpty(); // Show "Select from explore"
//         }
//       },
//       leading: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 20.0),
//         child: Icon(
//           Iconsax.book_1,
//           color: theme.primaryColor,
//           size: 32,
//         ),
//       ),
//       destinations: const [
//         NavigationRailDestination(
//           icon: Icon(Iconsax.home_1),
//           selectedIcon: Icon(Iconsax.home_1, weight: 900),
//           label: Text("Home"),
//         ),
//         NavigationRailDestination(
//           icon: Icon(Iconsax.folder_copy),
//           selectedIcon: Icon(Iconsax.folder_copy, weight: 900),
//           label: Text("Library"),
//         ),
//         NavigationRailDestination(
//           icon: Icon(Icons.explore_outlined),
//           selectedIcon: Icon(Icons.explore),
//           label: Text("Explore"),
//         ),
//       ],
//       trailing: Expanded(
//         child: Align(
//           alignment: Alignment.bottomCenter,
//           child: Padding(
//             padding: const EdgeInsets.only(bottom: 20.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: Icon(Iconsax.message_question, color: theme.onBackground.withOpacity(0.6)),
//                   tooltip: "Ask AI",
//                   onPressed: () {
//                     // Toggle the AI Panel
//                     ref.read(aiPanelProvider.notifier).update((state) => !state);
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 IconButton(
//                   icon: Icon(Iconsax.setting_2, color: theme.onBackground.withOpacity(0.6)),
//                   tooltip: "Settings",
//                   onPressed: showSettingsModal,
//                 ),
//                 const SizedBox(height: 16),
//                 IconButton(
//                   icon: Icon(Iconsax.user, color: theme.onBackground.withOpacity(0.6)),
//                   tooltip: "Profile",
//                   onPressed: () => GlobalNav.openDrawer(), // Reuses your existing mobile drawer logic
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// ```eof
// ```dart:Desktop Master Pane:lib/features/desktop/presentation/shell/desktop_master_pane.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/features/desktop/presentation/features/home/desktop_home_master.dart';
// import 'package:slidesync/features/desktop/presentation/features/library/desktop_library_master.dart';
// import 'package:slidesync/features/main/presentation/main/logic/main_provider.dart';

// /// Pane 2: The "Master" list pane.
// /// Its content switches based on the NavRail selection.
// class DesktopMasterPane extends ConsumerWidget {
//   const DesktopMasterPane({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final tabIndex = ref.watch(MainProvider.tabIndexProvider);

//     // Use an IndexedStack to preserve the state of each master view
//     // (e.g., scroll position in the library list).
//     return SizedBox(
//       width: 360,
//       child: IndexedStack(
//         index: tabIndex,
//         children: const [
//           // Corresponds to "Home"
//           DesktopHomeMaster(),
          
//           // Corresponds to "Library"
//           DesktopLibraryMaster(),
          
//           // Corresponds to "Explore"
//           // TODO: Build DesktopExploreMaster
//           Center(child: Text("Explore Master Pane")),
//         ],
//       ),
//     );
//   }
// }
// ```eof
// ```dart:Desktop Detail Pane:lib/features/desktop/presentation/shell/desktop_detail_pane.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/features/desktop/presentation/features/library/desktop_course_detail_view.dart';
// import 'package:slidesync/features/desktop/presentation/providers/desktop_shell_provider.dart';
// import 'package:slidesync/features/main/presentation/home/ui/home_tab_view/src/home_body/home_dashboard.dart';
// import 'package:slidesync/features/main/presentation/home/ui/home_tab_view/src/home_body/recents_section/recents_section_body.dart';
// import 'package:slidesync/features/study/presentation/views/content_view_gate.dart';
// import 'package:slidesync/shared/helpers/extensions/extensions.dart';

// /// Pane 3: The "Detail" content pane.
// /// This is the largest area, showing the content of the selected item.
// class DesktopDetailPane extends ConsumerWidget {
//   const DesktopDetailPane({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(detailPaneProvider);
//     final theme = ref.theme;

//     // Use AnimatedSwitcher for a smooth transition between content types.
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 200),
//       child: switch (state) {
//         // --- Empty State ---
//         DetailPaneEmpty() => Container(
//             key: const ValueKey('empty'),
//             color: theme.background.withOpacity(0.5),
//             child: Center(
//               child: Text(
//                 "Select an item from the list",
//                 style: TextStyle(color: theme.onBackground.withOpacity(0.5)),
//               ),
//             ),
//           ),
        
//         // --- Home: Dashboard ---
//         DetailPaneDashboard() => Container(
//             key: const ValueKey('dashboard'),
//             // We can reuse the mobile HomeDashboard widget directly
//             child: const SingleChildScrollView(
//               padding: EdgeInsets.all(24),
//               child: HomeDashboard(),
//             ),
//           ),
          
//         // --- Home: Recents ---
//         DetailPaneRecents() => Container(
//             key: const ValueKey('recents'),
//             // We can reuse the mobile RecentsSectionBody widget directly
//             child: const RecentsSectionBody(),
//           ),
          
//         // --- Library: Course Details ---
//         DetailPaneCourse(:final course) => Container(
//             key: ValueKey('course_${course.id}'),
//             // This is a new desktop-specific view that *internally*
//             // reuses mobile components.
//             child: DesktopCourseDetailView(course: course),
//           ),
          
//         // --- Study: Content Viewer ---
//         DetailPaneContent(:final content) => Container(
//             key: ValueKey('content_${content.id}'),
//             // We reuse the *entire* mobile content viewer flow.
//             // The PdfDocViewer, ImageViewer, etc., will all live
//             // inside this pane.
//             child: ContentViewGate(content: content),
//           ),
//       },
//     );
//   }
// }
// ```eof
// ```dart:Desktop Home Master:lib/features/desktop/presentation/features/home/desktop_home_master.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:slidesync/features/desktop/presentation/providers/desktop_shell_provider.dart';
// import 'package:slidesync/shared/helpers/extensions/extensions.dart';

// /// The master list for the "Home" section.
// /// Shows "Dashboard" and "Recents".
// class DesktopHomeMaster extends ConsumerWidget {
//   const DesktopHomeMaster({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.theme;
//     final detailState = ref.watch(detailPaneProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: theme.background,
//         elevation: 0,
//       ),
//       body: ListView(
//         children: [
//           ListTile(
//             leading: const Icon(Iconsax.element_4),
//             title: const Text("Dashboard"),
//             selected: detailState is DetailPaneDashboard,
//             selectedTileColor: theme.primaryColor.withOpacity(0.1),
//             onTap: () {
//               ref.read(detailPaneProvider.notifier).state = const DetailPaneDashboard();
//             },
//           ),
//           ListTile(
//             leading: const Icon(Iconsax.clock),
//             title: const Text("Recents"),
//             selected: detailState is DetailPaneRecents,
//             selectedTileColor: theme.primaryColor.withOpacity(0.1),
//             onTap: () {
//               ref.read(detailPaneProvider.notifier).state = const DetailPaneRecents();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
// ```eof
// ```dart:Desktop Library Master:lib/features/desktop/presentation/features/library/desktop_library_master.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:iconsax_flutter/iconsax_flutter.dart';
// import 'package:slidesync/features/desktop/presentation/providers/desktop_shell_provider.dart';
// import 'package:slidesync/features/main/presentation/library/logic/library_tab_provider.dart';
// import 'package:slidesync/features/main/presentation/library/ui/src/courses_view/course_card/list_course_card.dart';
// import 'package:slidesync/features/main/presentation/library/ui/src/courses_view/empty_library_view.dart';
// import 'package:slidesync/features/main/presentation/library/ui/src/library_search_view/library_search_view.dart';
// import 'package:slidesync/features/main/presentation/library/ui/src/library_tab_view_app_bar/library_tab_view_filter_button.dart';
// import 'package:slidesync/features/manage/presentation/courses/ui/create_course_view.dart';
// import 'package:slidesync/shared/helpers/extensions/extensions.dart';
// import 'package:slidesync/shared/widgets/dialogs/app_customizable_dialog.dart';
// import 'package:slidesync/shared/widgets/progress_indicator/circular_loading_indicator.dart';

// /// The master list for the "Library" section.
// /// This is the most important master view. It reuses the mobile Library logic.
// class DesktopLibraryMaster extends ConsumerWidget {
//   const DesktopLibraryMaster({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = ref.theme;
//     final coursesAsync = ref.watch(LibraryTabProvider.coursesProvider);
//     final detailState = ref.watch(detailPaneProvider);

//     return Scaffold(
//       backgroundColor: theme.background,
//       appBar: AppBar(
//         title: const Text("Library", style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: theme.background,
//         elevation: 0,
//         actions: const [
//           LibraryTabViewFilterButton(), // Reuse mobile filter button
//           SizedBox(width: 8),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//             // Reuse the mobile LibrarySearchView widget
//             child: LibrarySearchView(
//               onSearch: (query) =>
//                   ref.read(LibraryTabProvider.searchQueryProvider.notifier).state = query,
//             ),
//           ),
//         ),
//       ),
//       body: coursesAsync.when(
//         data: (courses) {
//           if (courses.isEmpty) {
//             // Reuse the mobile EmptyLibraryView
//             return const EmptyLibraryView();
//           }
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: courses.length,
//             itemBuilder: (context, index) {
//               final course = courses[index];
//               // Reuse the mobile ListCourseCard
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 10.0),
//                 child: ListCourseCard(
//                   course: course,
//                   // Check if this course is the one selected in the detail pane
//                   isSelected: detailState is DetailPaneCourse && detailState.course.id == course.id,
//                   onTap: () {
//                     // When tapped, update the detail pane to show this course
//                     ref.read(detailPaneProvider.notifier).state = DetailPaneCourse(course);
//                   },
//                 ),
//               );
//             },
//           );
//         },
//         loading: () => const CenteredCircularLoadingIndicator(),
//         error: (e, s) => Center(child: Text("Error: $e")),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: const Icon(Iconsax.add),
//         label: const Text("Create Course"),
//         onPressed: () {
//           // Reuse the mobile CreateCourseView, but show it in a modal dialog
//           AppCustomizableDialog.show(
//             context,
//             child: const CreateCourseView(),
//             maxWidth: 700,
//           );
//         },
//       ),
//     );
//   }
// }
// ```eof
// ```dart:Desktop Course Detail View:lib/features/desktop/presentation/features/library/desktop_course_detail_view.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/data/models/course_model/course.dart';
// import 'package:slidesync/features/browse/presentation/ui/course_details/course_details_collection_section.dart';
// import 'package:slidesync/features/browse/presentation/ui/course_details/course_details_header.dart';
// import 'package:slidesync/features/desktop/presentation/providers/desktop_shell_provider.dart';
// import 'package:slidesync/features/manage/presentation/courses/ui/modify_course_view.dart';
// import 'package:slidesync/shared/helpers/extensions/extensions.dart';

// /// The detail view for a selected course.
// /// This is a new widget that toggles between "Browsing" (reusing `browse` widgets)
// /// and "Editing" (reusing `manage` widgets).
// class DesktopCourseDetailView extends ConsumerStatefulWidget {
//   final Course course;
//   const DesktopCourseDetailView({super.key, required this.course});

//   @override
//   ConsumerState<DesktopCourseDetailView> createState() => _DesktopCourseDetailViewState();
// }

// class _DesktopCourseDetailViewState extends ConsumerState<DesktopCourseDetailView> {
//   bool _isEditing = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = ref.theme;

//     // This is the "Browse" state
//     if (!_isEditing) {
//       return Scaffold(
//         backgroundColor: theme.scaffoldBackgroundColor,
//         appBar: AppBar(
//           title: Text(widget.course.title, overflow: TextOverflow.ellipsis),
//           actions: [
//             TextButton.icon(
//               icon: const Icon(Icons.edit_outlined),
//               label: const Text("Edit"),
//               onPressed: () => setState(() => _isEditing = true),
//             ),
//             const SizedBox(width: 16),
//           ],
//         ),
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               // Reuse mobile CourseDetailsHeader
//               CourseDetailsHeader(course: widget.course),
//               // Reuse mobile CourseDetailsCollectionSection
//               // We pass our desktop provider's notifier to handle clicks
//               CourseDetailsCollectionSection(
//                 course: widget.course,
//                 onContentTap: (content) {
//                   // When content is tapped, update the detail pane
//                   // to show the content viewer.
//                   ref.read(detailPaneProvider.notifier).state = DetailPaneContent(content);
//                 },
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // This is the "Edit" state
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: Text("Editing: ${widget.course.title}", overflow: TextOverflow.ellipsis),
//         actions: [
//           TextButton.icon(
//             icon: const Icon(Icons.done),
//             label: const Text("Done"),
//             onPressed: () => setState(() => _isEditing = false),
//           ),
//           const SizedBox(width: 16),
//         ],
//       ),
//       body: SingleChildScrollView(
//         // Reuse the *entire* mobile ModifyCourseView.
//         // This is extremely powerful, as all your "manage" logic
//         // is brought into the desktop UI automatically.
//         child: ModifyCourseView(
//           course: widget.course,
//           // We need to pass the same content tap handler
//           onContentTap: (content) {
//             ref.read(detailPaneProvider.notifier).state = DetailPaneContent(content);
//           },
//         ),
//       ),
//     );
//   }
// }
// ```eof
// ```dart:Desktop AI Panel:lib/features/desktop/presentation/overlays/desktop_ai_panel.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:slidesync/features/ask_ai/presentation/ui/ai_interaction_view.dart';
// import 'package:slidesync/features/desktop/presentation/providers/desktop_shell_provider.dart';
// import 'package:slidesync/shared/helpers/extensions/extensions.dart';

// /// The "Ask AI" panel that slides in from the right.
// class DesktopAiPanel extends ConsumerWidget {
//   const DesktopAiPanel({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isVisible = ref.watch(aiPanelProvider);
//     final theme = ref.theme;
//     final screenWidth = MediaQuery.of(context).size.width;
//     const panelWidth = 400.0;

//     return AnimatedPositioned(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       right: isVisible ? 0 : -panelWidth,
//       top: 0,
//       bottom: 0,
//       width: panelWidth,
//       child: Material(
//         elevation: 16,
//         child: Container(
//           width: panelWidth,
//           color: theme.background,
//           child: Column(
//             children: [
//               AppBar(
//                 title: const Text("Ask AI"),
//                 leading: IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => ref.read(aiPanelProvider.notifier).state = false,
//                 ),
//                 backgroundColor: theme.background,
//                 elevation: 1,
//               ),
//               // Reuse the mobile AiInteractionView
//               const Expanded(
//                 child: AiInteractionView(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// ```eof