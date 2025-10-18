part of '../extensions.dart';

extension NumDurationExtension on num {
  Duration get inMicroseconds => Duration(microseconds: round());
  Duration get inMs => (this * 1000).inMicroseconds;
  Duration get inMilliseconds => (this * 1000).inMicroseconds;
  Duration get inSeconds => (this * 1000 * 1000).inMicroseconds;
  Duration get inMinutes => (this * 1000 * 1000 * 60).inMicroseconds;
  Duration get inHours => (this * 1000 * 1000 * 60 * 60).inMicroseconds;
  Duration get inDays => (this * 1000 * 1000 * 60 * 60 * 24).inMicroseconds;
}
