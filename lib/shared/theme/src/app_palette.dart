import 'dart:math';
import 'package:flutter/material.dart';

class AppPalette {
  // 1. Modern SaaS (Indigo & Blues)
  static const Color indigo = Color(0xFF6366F1);
  static const Color deepIndigo = Color(0xFF4F46E5);
  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color royalBlue = Color(0xFF2563EB);
  static const Color skyBlue = Color(0xFF0EA5E9);
  static const Color oceanBlue = Color(0xFF0284C7);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color deepCyan = Color(0xFF0891B2);
  static const Color teal = Color(0xFF14B8A6);
  static const Color forestTeal = Color(0xFF0D9488);

  // 2. Soft Luxury (Violets & Purples)
  static const Color violet = Color(0xFF8B5CF6);
  static const Color deepViolet = Color(0xFF7C3AED);
  static const Color purple = Color(0xFFA855F7);
  static const Color amethyst = Color(0xFF9333EA);
  static const Color fuchsia = Color(0xFFD946EF);
  static const Color deepFuchsia = Color(0xFFC026D3);
  static const Color softLavender = Color(0xFF818CF8);
  static const Color royalPurple = Color(0xFF6D28D9);
  static const Color midnightPurple = Color(0xFF4C1D95);
  static const Color deepSpace = Color(0xFF2E1065);

  // 3. Nature & Growth (Emeralds & Greens)
  static const Color emerald = Color(0xFF10B981);
  static const Color deepEmerald = Color(0xFF059669);
  static const Color grassGreen = Color(0xFF22C55E);
  static const Color forestGreen = Color(0xFF16A34A);
  static const Color mint = Color(0xFF34D399);
  static const Color lime = Color(0xFF4ADE80);
  static const Color darkGrass = Color(0xFF15803D);
  static const Color evergreen = Color(0xFF065F46);
  static const Color aquamarine = Color(0xFF2DD4BF);
  static const Color deepSea = Color(0xFF115E59);

  // 4. Gold & Amber (Warmth without Red)
  static const Color amber = Color(0xFFF59E0B);
  static const Color burntAmber = Color(0xFFD97706);
  static const Color goldenrod = Color(0xFFFBBF24);
  static const Color sunshineYellow = Color(0xFFEAB308);
  static const Color mustard = Color(0xFFCA8A04);
  static const Color darkGold = Color(0xFF854D0E);
  static const Color oak = Color(0xFF713F12);
  static const Color bronze = Color(0xFFA16207);
  static const Color copper = Color(0xFFB45309);
  static const Color brightGold = Color(0xFFFACC15);

  // 5. Sophisticated Slates (Neutral / UI)
  static const Color slate = Color(0xFF64748B);
  static const Color coolGray = Color(0xFF475569);
  static const Color deepSlate = Color(0xFF334155);
  static const Color darkNavy = Color(0xFF1E293B);
  static const Color richMidnight = Color(0xFF0F172A);
  static const Color blueSteel = Color(0xFF94A3B8);
  static const Color platinum = Color(0xFFCBD5E1);
  static const Color charcoal = Color(0xFF111827);
  static const Color iron = Color(0xFF374151);
  static const Color granite = Color(0xFF4B5563);

  /// All 50 premium colors in one list
  static const List<Color> all = [
    indigo,
    deepIndigo,
    electricBlue,
    royalBlue,
    skyBlue,
    oceanBlue,
    cyan,
    deepCyan,
    teal,
    forestTeal,
    violet,
    deepViolet,
    purple,
    amethyst,
    fuchsia,
    deepFuchsia,
    softLavender,
    royalPurple,
    midnightPurple,
    deepSpace,
    emerald,
    deepEmerald,
    grassGreen,
    forestGreen,
    mint,
    lime,
    darkGrass,
    evergreen,
    aquamarine,
    deepSea,
    amber,
    burntAmber,
    goldenrod,
    sunshineYellow,
    mustard,
    darkGold,
    oak,
    bronze,
    copper,
    brightGold,
    slate,
    coolGray,
    deepSlate,
    darkNavy,
    richMidnight,
    blueSteel,
    platinum,
    charcoal,
    iron,
    granite,
  ];

  /// Returns a random color from the premium list
  static Color getRandom() {
    return all[Random().nextInt(all.length)];
  }
}
