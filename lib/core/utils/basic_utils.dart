import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:xxh3/xxh3.dart';

class BasicUtils {
  static Future<String> calculatePartialHash(String path, {int chunkSize = 32 * 1024}) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('File does not exist', path);
    }

    final length = await file.length();

    // Setup sha sink
    final completer = Completer<Digest>();
    final outSink = ChunkedConversionSink<Digest>.withCallback((digests) {
      completer.complete(digests.single);
    });
    final hashSink = sha256.startChunkedConversion(outSink);

    try {
      if (length <= chunkSize * 2) {
        // small file: stream whole file (no large alloc)
        await for (final chunk in file.openRead()) {
          hashSink.add(chunk);
        }
      } else {
        // Large file: open once and read both chunks using RandomAccessFile
        final raf = await file.open();
        try {
          // Read first chunk
          final first = await raf.read(chunkSize);
          hashSink.add(first);

          // Seek to last chunk and read
          await raf.setPosition(length - chunkSize);
          final last = await raf.read(chunkSize);
          hashSink.add(last);
        } finally {
          await raf.close();
        }
      }

      // Mix in size bytes
      hashSink.add(utf8.encode(length.toString()));
      hashSink.close();

      final digest = await completer.future;
      return digest.toString();
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> calculateFileHash(String path) async {
    final file = File(path);
    final input = file.openRead(); // Stream<List<int>>
    final digest = await sha256.bind(input).first;
    return digest.toString();
  }

  static String calculateStringHash(String str) {
    final bytes = utf8.encode(str);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<String> calculateFileHashXXH3(String path) async {
    final file = File(path);
    final Stream<List<int>> input = file.openRead();
    final hashStream = xxh3Stream();

    await for (final chunk in input) {
      hashStream.update(Uint8List.fromList(chunk));
    }

    return hashStream.digestString();
  }

  static Future<int> getFilesSize(List<File> files) async {
    int total = 0;
    for (final file in files) {
      total += await file.length();
    }
    return total;
  }

  static Future<int> getFileSize(String path) async {
    final file = File(path);
    return await file.length();
  }
}
