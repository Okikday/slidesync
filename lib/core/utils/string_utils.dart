class StringUtils {
  /// Extracts the first two and second two characters from a hash string
  ///
  /// [hash] - The hash string (e.g., "ffb95280-c3ae-4859-8993-680782d5b31d")
  /// Returns format: "xx/yy" (e.g., "ff/b9")
  /// Returns empty string if hash is invalid
  static String getHashPrefixAsDir(String hash) {
    if (hash.isEmpty || hash.length < 4) {
      return '';
    }
    return '${hash.substring(0, 2)}/${hash.substring(2, 4)}';
  }

  /// Extracts hash prefix with year/month prepended
  ///
  /// [hash] - The hash string
  /// [date] - Optional DateTime object (defaults to current date)
  /// Returns format: "YYYY/MM/xx/yy" (e.g., "2025/05/ff/b9")
  static String getHashPrefixAsDirWithDate(String hash, [DateTime? date]) {
    final dateTime = date ?? DateTime.now();
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final hashPrefix = getHashPrefixAsDir(hash);

    return '$year/$month/$hashPrefix';
  }
}
