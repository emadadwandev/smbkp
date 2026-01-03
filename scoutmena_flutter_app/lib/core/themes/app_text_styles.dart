import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font Families
  static const String fontFamilyEnglish = 'Tomorrow';
  static const String fontFamilyArabic = 'Cairo';

  // English Text Styles
  static const TextStyle h1English = TextStyle(
    fontFamily: fontFamilyEnglish,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2English = TextStyle(
    fontFamily: fontFamilyEnglish,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3English = TextStyle(
    fontFamily: fontFamilyEnglish,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyEnglish = TextStyle(
    fontFamily: fontFamilyEnglish,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle captionEnglish = TextStyle(
    fontFamily: fontFamilyEnglish,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle buttonEnglish = TextStyle(
    fontFamily: fontFamilyEnglish,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  // Arabic Text Styles
  static const TextStyle h1Arabic = TextStyle(
    fontFamily: fontFamilyArabic,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h2Arabic = TextStyle(
    fontFamily: fontFamilyArabic,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle h3Arabic = TextStyle(
    fontFamily: fontFamilyArabic,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyArabic = TextStyle(
    fontFamily: fontFamilyArabic,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.7,
  );

  static const TextStyle captionArabic = TextStyle(
    fontFamily: fontFamilyArabic,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const TextStyle buttonArabic = TextStyle(
    fontFamily: fontFamilyArabic,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Helper method to get text style based on locale
  static TextStyle getH1(bool isArabic) => isArabic ? h1Arabic : h1English;
  static TextStyle getH2(bool isArabic) => isArabic ? h2Arabic : h2English;
  static TextStyle getH3(bool isArabic) => isArabic ? h3Arabic : h3English;
  static TextStyle getBody(bool isArabic) => isArabic ? bodyArabic : bodyEnglish;
  static TextStyle getCaption(bool isArabic) => isArabic ? captionArabic : captionEnglish;
  static TextStyle getButton(bool isArabic) => isArabic ? buttonArabic : buttonEnglish;
}
