import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/features/main/presentation/library/logic/library_tab_provider.dart';
import 'package:slidesync/features/main/presentation/library/ui/src/library_tab_view_app_bar.dart';
import 'package:slidesync/features/main/presentation/library/ui/library_tab_body.dart';

class LibraryTabView extends ConsumerStatefulWidget {
  const LibraryTabView({super.key});

  @override
  ConsumerState createState() => _LibraryTabViewState();
}

class _LibraryTabViewState extends ConsumerState<LibraryTabView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NestedScrollView(
      controller: ref.watch(LibraryTabProvider.state).scrollController,
      physics: const NeverScrollableScrollPhysics(),
      headerSliverBuilder: (context, isInnerBoxScrolled) => const [LibraryTabViewAppBar()],

      body: const LibraryTabBody(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
