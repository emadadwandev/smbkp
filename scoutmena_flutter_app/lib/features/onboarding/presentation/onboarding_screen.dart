import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../app/routes.dart';

class OnboardingPage {
  final String image;
  final String title;
  final String subtitle;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/images/ScoutMenaRealisticOnboardingImage_2.png',
      title: 'onboarding.build_profile_title',
      subtitle: 'onboarding.build_profile_subtitle',
    ),
    OnboardingPage(
      image: 'assets/images/ScoutMenaRealisticOnboardingImage_1.png',
      title: 'onboarding.discover_title',
      subtitle: 'onboarding.discover_subtitle',
    ),
    OnboardingPage(
      image: 'assets/images/ScoutMenaRealisticOnboardingImage_3.png',
      title: 'onboarding.get_discovered_title',
      subtitle: 'onboarding.get_discovered_subtitle',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _skipOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo and Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Empty container to balance the Skip button if we want logo centered
                  // Or we can just put the logo in the center of the screen width using a Stack or expanded
                  const SizedBox(width: 48), 
                  
                  // Logo
                  Image.asset(
                    'assets/images/Main logo.png',
                    height: 40,
                    errorBuilder: (c, o, s) => const Icon(Icons.sports_soccer, size: 40, color: Colors.blue),
                  ),

                  // Skip Button
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'onboarding.skip'.tr(),
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  // Calculate scale for the current item to give a nice effect
                  // But for now, simple cards as per design
                  return _buildPage(_pages[index], index == _currentPage, textColor, subtitleColor!);
                },
              ),
            ),

            // Indicators
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Next Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4), // Blue color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'onboarding.get_started'.tr()
                        : 'onboarding.next'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, bool isActive, Color titleColor, Color subtitleColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Card
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Dark card background
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: AssetImage(page.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Text Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.title.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.subtitle.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 6.0),
      width: 12.0,
      height: 12.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4285F4) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? const Color(0xFF4285F4) : Colors.grey,
          width: 1.5,
        ),
      ),
    );
  }
}
