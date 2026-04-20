import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:slidesync/features/main/ui/screens/home_tab_view.dart';
import 'package:slidesync/features/main/ui/screens/library_tab_view.dart';
import 'package:slidesync/features/sync/ui/screens/sync_view.dart';

final mainViewTabOptions = <Widget, ({String label, String tooltip, IconData icon, IconData activeIcon})>{
  const HomeTabView(): (
    label: "Home",
    tooltip: "Home",
    icon: HugeIconsStroke.home01,
    activeIcon: HugeIconsSolid.home01,
  ),
  const LibraryTabView(): (
    label: "Library",
    tooltip: "Library holding all your courses",
    icon: HugeIconsStroke.folder01,
    activeIcon: HugeIconsSolid.folder01,
  ),
  const SyncView(): (
    label: "Sync",
    tooltip: "Sync details",
    icon: HugeIconsStroke.fileSync,
    activeIcon: HugeIconsSolid.fileSync,
  ),
};
