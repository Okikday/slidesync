import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:xxh3/xxh3.dart';

class CryptoUtils {
  /// Calculates the XXH3 hash of a file (appended with it's length/size) at the given [path].
  /// Returns the hash as a hexadecimal string.
  static Future<String> calculateFileHashXXH3(String path) async {
    final file = File(path);
    final length = await file.length();

    final hashStream = xxh3Stream();
    final Stream<List<int>> input = file.openRead();

    await for (final chunk in input) {
      hashStream.update(Uint8List.fromList(chunk));
    }
    return '${hashStream.digestString()}_$length';
  }

  static String calculateStringHash(String str) {
    final bytes = utf8.encode(str);
    final digest = xxh3String(bytes);
    return digest;
  }
}
