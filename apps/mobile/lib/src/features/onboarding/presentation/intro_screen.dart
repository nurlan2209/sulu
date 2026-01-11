import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:damu_app/gen_l10n/app_localizations.dart';
import '../../../core/storage/prefs.dart';
import '../../../ui/damu_colors.dart';
import '../../auth/presentation/session_controller.dart';

class IntroSplashScreen extends ConsumerStatefulWidget {
  const IntroSplashScreen({super.key});

  @override
  ConsumerState<IntroSplashScreen> createState() => _IntroSplashScreenState();
}

class _IntroSplashScreenState extends ConsumerState<IntroSplashScreen> {
  static const _seenKey = 'onboarding_intro_seen';
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setBool(_seenKey, true);

    final session = ref.read(sessionControllerProvider).valueOrNull;
    final profileReady = session?.user.dailyWaterGoal != null && (session?.user.dailyWaterGoal ?? 0) > 0;
    if (!mounted) return;
    context.go(profileReady ? '/home' : '/onboarding/goal');
  }

  void _handleNext() {
    if (_page < 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final pages = [
      _IntroPageData(
        image: 'assets/images/splash_drop.png',
        title: t.splashTitle1,
        body: t.splashBody1,
      ),
      _IntroPageData(
        image: 'assets/images/splash_woman.png',
        title: t.splashTitle2,
        body: t.splashBody2,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_page == 0)
                    const SizedBox(width: 44, height: 44)
                  else
                    IconButton(
                      onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new),
                      color: DamuColors.primary,
                    ),
                  TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF2CA3C0)),
                    child: Text(t.splashSkip),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  final width = MediaQuery.sizeOf(context).width;
                  final imageSize = width * 0.65;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Expanded(
                          child: Center(
                            child: Image.asset(
                              page.image,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: DamuColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: DamuColors.textMuted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  );
                },
              ),
            ),
            _PageDots(activeIndex: _page, count: pages.length),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2CA3C0),
                    foregroundColor: Colors.white,
                    elevation: 6,
                    shadowColor: const Color(0xFF2CA3C0).withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 0.6),
                  ),
                  child: Text(t.splashNext),
                ),
              ),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int activeIndex;
  final int count;
  const _PageDots({required this.activeIndex, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 14,
          height: 6,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF2CA3C0) : DamuColors.textMutedLight,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}

class _IntroPageData {
  final String image;
  final String title;
  final String body;
  const _IntroPageData({required this.image, required this.title, required this.body});
}
