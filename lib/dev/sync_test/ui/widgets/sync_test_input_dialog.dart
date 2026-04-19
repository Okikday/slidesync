import 'package:flutter/material.dart';

class SyncTestInputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final Function(String) onSubmit;

  const SyncTestInputDialog({super.key, required this.title, required this.hintText, required this.onSubmit});

  @override
  State<SyncTestInputDialog> createState() => _SyncTestInputDialogState();
}

class _SyncTestInputDialogState extends State<SyncTestInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: widget.hintText, border: const OutlineInputBorder()),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _controller.text.isEmpty
              ? null
              : () {
                  widget.onSubmit(_controller.text);
                  Navigator.pop(context);
                },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

class SyncTestSyncInputDialog extends StatefulWidget {
  final Function(String, List<String>) onSubmit;

  const SyncTestSyncInputDialog({super.key, required this.onSubmit});

  @override
  State<SyncTestSyncInputDialog> createState() => _SyncTestSyncInputDialogState();
}

class _SyncTestSyncInputDialogState extends State<SyncTestSyncInputDialog> {
  late TextEditingController _courseIdController;
  late TextEditingController _vaultLinksController;

  @override
  void initState() {
    super.initState();
    _courseIdController = TextEditingController();
    _vaultLinksController = TextEditingController();
  }

  @override
  void dispose() {
    _courseIdController.dispose();
    _vaultLinksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Course'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _courseIdController,
              decoration: const InputDecoration(
                labelText: 'Course ID',
                hintText: 'e.g., course-123',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _vaultLinksController,
              decoration: const InputDecoration(
                labelText: 'Vault Links',
                hintText: 'Comma-separated URLs',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _courseIdController.text.isEmpty
              ? null
              : () {
                  final vaultLinks = _vaultLinksController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  widget.onSubmit(_courseIdController.text, vaultLinks);
                  Navigator.pop(context);
                },
          child: const Text('Sync'),
        ),
      ],
    );
  }
}
