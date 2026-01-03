import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// ScoutMena Logo Widget
/// 
/// Displays the appropriate ScoutMena logo based on current language.
/// - English: Shows "Main logo.png"
/// - Arabic: Shows "Main logo Arabic.png"
class ScoutMenaLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const ScoutMenaLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    final logoPath = isArabic 
        ? 'assets/images/Main logo Arabic.png'
        : 'assets/images/Main logo.png';

    return Image.asset(
      logoPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to placeholder if image fails to load
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.sports_soccer,
            size: 60,
            color: Colors.white,
          ),
        );
      },
    );
  }
}

/// App Icon Widget
/// 
/// Displays the ScoutMena app icon
class ScoutMenaAppIcon extends StatelessWidget {
  final double size;

  const ScoutMenaAppIcon({
    super.key,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/App Icon.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to placeholder if image fails to load
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sports_soccer,
            size: size * 0.5,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
