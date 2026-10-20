import 'package:flutter/material.dart';

abstract final class AppColors {
  static const purple = Color(0xFF4404AC);
  static const yellow = Color(0xFFDDB90E);
  static const red = Color(0xFFEC4A4B);
  static const pink = Color(0xFFEF9899);
  static const ink = Color(0xFF1E2022);
  static const muted = Color(0xFF77838F);
  static const surface = Color(0xFFF1F3F5);
  static const avatar = Color(0xFFD8D8D8);
}

TextStyle type({
  double size = 15.6,
  Color color = AppColors.ink,
  FontWeight weight = FontWeight.w400,
  double spacing = 1,
  double? height,
}) => TextStyle(
  fontSize: size,
  color: color,
  fontWeight: weight,
  letterSpacing: spacing,
  height: height ?? 1.2,
);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.purple,
    primary: AppColors.purple,
    secondary: AppColors.yellow,
    surface: Colors.white,
  ),
  fontFamily: '.SF UI Text',
  textTheme: TextTheme(bodyMedium: type(), bodySmall: type(size: 13.6)),
  splashFactory: InkRipple.splashFactory,
  dividerColor: const Color(0xFFEEEEEE),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.zero,
  ),
);
