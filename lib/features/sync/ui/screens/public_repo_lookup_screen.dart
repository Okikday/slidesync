import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slidesync/core/apis/api.dart';
import 'package:slidesync/core/apis/entities/content_entity.dart';
import 'package:slidesync/core/apis/entities/collection_entity.dart';
import 'package:slidesync/core/apis/entities/course_entity.dart';
import 'package:slidesync/core/apis/entities/source_entity.dart';
import 'package:slidesync/core/utils/ui_utils.dart';

class PublicRepoLookupScreen extends ConsumerStatefulWidget {
  const PublicRepoLookupScreen({Key? key}) : super(key: key);

  @override
  PublicRepoLookupScreenState createState() => PublicRepoLookupScreenState();
}

class PublicRepoLookupScreenState extends ConsumerState<PublicRepoLookupScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  CourseEntity? _course;
  List<CollectionEntity> _collections = [];
  List<ContentEntity> _contents = [];
  ContentEntity? _content;
  List<SourceEntity> _sources = [];

  Future<void> _search() async {
    final uid = _controller.text.trim();
    if (uid.isEmpty) return;
    setState(() {
      _loading = true;
      _course = null;
      _collections = [];
      _contents = [];
      _content = null;
      _sources = [];
    });

    // Try course first
    final courseRes = await Api.instance.courses.get(uid);
    if (courseRes.isSuccess && courseRes.data != null) {
      final course = courseRes.data!;
      setState(() => _course = course);
      final collPage = await Api.instance.collections.list(courseId: course.courseId, limit: 200);
      if (collPage.isSuccess && collPage.data != null) {
        setState(() => _collections = collPage.data!.items);
      }
      setState(() => _loading = false);
      return;
    }

    // Try content id
    final contentRes = await Api.instance.content.get(uid);
    if (contentRes.isSuccess && contentRes.data != null) {
      setState(() => _content = contentRes.data);
      final sourcesPage = await Api.instance.sources.list(xxh3Hash: _content!.xxh3Hash, limit: 50);
      if (sourcesPage.isSuccess && sourcesPage.data != null) setState(() => _sources = sourcesPage.data!.items);
      setState(() => _loading = false);
      return;
    }

    // Not found
    setState(() => _loading = false);
    UiUtils.showFlushBar(context, msg: 'No course or content found for "$uid"', vibe: FlushbarVibe.warning);
  }

  Future<void> _loadContentsForCollection(String collectionId) async {
    setState(() => _loading = true);
    final page = await Api.instance.content.list(collectionId: collectionId, limit: 200);
    if (page.isSuccess && page.data != null) setState(() => _contents = page.data!.items);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Repo Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Course or Content UID'),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _search, child: const Text('Search')),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_course != null) ...[
                      Text('Course: ${_course!.courseTitle}', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(_course!.description),
                      const SizedBox(height: 12),
                      Text('Collections', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      for (final c in _collections)
                        ListTile(
                          title: Text(c.collectionTitle),
                          subtitle: Text(c.description),
                          trailing: TextButton(
                            onPressed: () => _loadContentsForCollection(c.collectionId),
                            child: const Text('Show contents'),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (_contents.isNotEmpty) ...[
                        Text('Contents', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        for (final it in _contents)
                          Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(it.title),
                              subtitle: Text('${it.type} — ${it.fileSize} bytes'),
                              trailing: TextButton(
                                onPressed: () async {
                                  final sourcesPage = await Api.instance.sources.list(xxh3Hash: it.xxh3Hash, limit: 50);
                                  if (sourcesPage.isSuccess && sourcesPage.data != null) {
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text('Sources for ${it.title}'),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: sourcesPage.data!.items
                                                .map(
                                                  (s) => ListTile(
                                                    title: Text(s.title ?? s.url),
                                                    subtitle: SelectableText(s.url ?? ''),
                                                    trailing: IconButton(
                                                      icon: const Icon(Icons.copy),
                                                      onPressed: () {
                                                        Clipboard.setData(ClipboardData(text: s.url ?? ''));
                                                        UiUtils.showFlushBar(
                                                          context,
                                                          msg: 'Copied source URL to clipboard',
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    UiUtils.showFlushBar(context, msg: 'No sources found');
                                  }
                                },
                                child: const Text('Sources'),
                              ),
                            ),
                          ),
                      ],
                    ],

                    if (_content != null) ...[
                      Text('Content: ${_content!.title}', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Type: ${_content!.type}'),
                      const SizedBox(height: 8),
                      Text('Description: ${_content!.description}'),
                      const SizedBox(height: 12),
                      Text('Sources', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      for (final s in _sources)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(s.title ?? s.url ?? ''),
                            subtitle: SelectableText(s.url ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: s.url ?? ''));
                                    UiUtils.showFlushBar(context, msg: 'Copied source URL');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
