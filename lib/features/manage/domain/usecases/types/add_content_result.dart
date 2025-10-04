class AddContentResult {
  final bool hasDuplicate;
  final bool isSuccess;
  final String? contentId;
  final String fileName;

  AddContentResult({this.hasDuplicate = false, required this.isSuccess, this.contentId, required this.fileName});
}
