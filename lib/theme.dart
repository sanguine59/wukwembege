import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const blue = Color(0xFF2563EB);
  static const bluePress = Color(0xFF1D4ED8);
  static const blueSoft = Color(0xFFEFF4FF);
  static const blueSofter = Color(0xFFF6F9FF);
  static const blueLine = Color(0xFFDCE7FF);

  static const canvas = Color(0xFFF6F7F9);
  static const surface = Colors.white;
  static const ink = Color(0xFF0E1726);
  static const text2 = Color(0xFF475569);
  static const text3 = Color(0xFF64748B);
  static const text4 = Color(0xFF94A3B8);
  static const border = Color(0xFFE7EBF0);
  static const divider = Color(0xFFEEF0F4);

  static const green = Color(0xFF15A35B);
  static const greenSoft = Color(0xFFE6F7EE);
  static const amber = Color(0xFFE0931A);
  static const amberSoft = Color(0xFFFDF1DE);
  static const red = Color(0xFFE5484D);
  static const redSoft = Color(0xFFFCE8EE);
  static const violet = Color(0xFF7C5CFC);
  static const violetSoft = Color(0xFFF0ECFF);
}

class ThumbPalette {
  final Color bg;
  final Color soft;
  const ThumbPalette(this.bg, this.soft);
}

const Map<String, ThumbPalette> kThumb = {
  'blue':   ThumbPalette(Color(0xFF2563EB), Color(0xFFEFF4FF)),
  'indigo': ThumbPalette(Color(0xFF4F46E5), Color(0xFFEEF0FF)),
  'teal':   ThumbPalette(Color(0xFF0E9488), Color(0xFFE4F6F4)),
  'amber':  ThumbPalette(Color(0xFFE08A1A), Color(0xFFFDF1DE)),
  'rose':   ThumbPalette(Color(0xFFE5436B), Color(0xFFFCE8EE)),
  'violet': ThumbPalette(Color(0xFF7C5CFC), Color(0xFFF0ECFF)),
  'green':  ThumbPalette(Color(0xFF15A35B), Color(0xFFE6F7EE)),
  'slate':  ThumbPalette(Color(0xFF475569), Color(0xFFEEF1F5)),
};

class AppShadows {
  static const sm = [BoxShadow(color: Color(0x0F0E1726), blurRadius: 6, offset: Offset(0, 2))];
  static const md = [BoxShadow(color: Color(0x14101935), blurRadius: 18, offset: Offset(0, 6))];
  static const lg = [BoxShadow(color: Color(0x1F101935), blurRadius: 24, offset: Offset(0, 10))];
  static const blue = [BoxShadow(color: Color(0x4D2563EB), blurRadius: 18, offset: Offset(0, 6))];
}

class AppRadii {
  static const r = 18.0;
  static const sm = 12.0;
  static const xs = 9.0;
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final txt = GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
    bodyColor: AppColors.ink,
    displayColor: AppColors.ink,
  );
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.blue,
      surface: AppColors.surface,
      onPrimary: Colors.white,
    ),
    textTheme: txt,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.canvas,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.ink,
      titleTextStyle: txt.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
    ),
    splashFactory: InkRipple.splashFactory,
  );
}
