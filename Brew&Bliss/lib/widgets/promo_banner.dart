import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/products.dart';
import '../screens/products/all_products_screen.dart';
import '../screens/products/product_detail_screen.dart';
import '../screens/rewards/reward_screen.dart';
import '../utils/page_transitions.dart';

// Where a slide's button takes the user.
enum _BannerAction { menu, allProducts, product, rewards }

class _BannerSlide {
  final _BannerAction action;
  final String? productName; // only for _BannerAction.product
  final String image;
  final String titleTop;
  final String titleBottom;
  final String subtitle;
  final String buttonText;

  const _BannerSlide({
    required this.action,
    this.productName,
    required this.image,
    required this.titleTop,
    required this.titleBottom,
    required this.subtitle,
    required this.buttonText,
  });
}

class PromoBanner extends StatefulWidget {
  /// Called when a slide wants to open the Menu tab (Home passes a callback
  /// that switches the bottom-nav tab).
  final VoidCallback? onOpenMenu;

  const PromoBanner({super.key, this.onOpenMenu});

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  final List<_BannerSlide> slides = const [
    _BannerSlide(
      action: _BannerAction.menu,
      image:
          'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=1000&q=85',
      titleTop: 'Good Coffee',
      titleBottom: 'Good Vibes',
      subtitle: 'Freshly brewed coffee made to brighten your day.',
      buttonText: 'ORDER NOW',
    ),
    _BannerSlide(
      action: _BannerAction.allProducts,
      image:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1000&q=85',
      titleTop: 'Weekend Special',
      titleBottom: '20% Off Today',
      subtitle: 'On all coffee orders above ₹299. Limited time only.',
      buttonText: 'GRAB OFFER',
    ),
    _BannerSlide(
      action: _BannerAction.product,
      productName: 'Cold Brew',
      image:
          'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=1000&q=85',
      titleTop: 'Cool & Bold',
      titleBottom: 'Cold Brew',
      subtitle: 'Slow-steeped for hours, smooth and refreshing.',
      buttonText: 'EXPLORE',
    ),
    _BannerSlide(
      action: _BannerAction.rewards,
      image:
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=1000&q=85',
      titleTop: 'Rewards Await',
      titleBottom: 'Earn & Redeem',
      subtitle: 'Collect points on every order and unlock free coffees.',
      buttonText: 'JOIN NOW',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % slides.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _handleAction(_BannerSlide slide) {
    HapticFeedback.selectionClick();

    switch (slide.action) {
      case _BannerAction.menu:
        widget.onOpenMenu?.call();
        break;
      case _BannerAction.allProducts:
        Navigator.push(context, slideTransition(const AllProductsScreen()));
        break;
      case _BannerAction.product:
        final product = allProducts.firstWhere(
          (p) => p.name == slide.productName,
          orElse: () => allProducts.first,
        );
        ProductDetailScreen.open(context, product);
        break;
      case _BannerAction.rewards:
        Navigator.push(context, slideTransition(const RewardsScreen()));
        break;
    }
  }

  void _restartAutoScroll() {
    _timer?.cancel();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 265,
          child: NotificationListener<ScrollNotification>(
            // Restart the auto-scroll timer whenever the user swipes
            // manually, so it doesn't fight with a manual swipe.
            onNotification: (notification) {
              if (notification is UserScrollNotification &&
                  notification.direction != ScrollDirection.idle) {
                _restartAutoScroll();
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return _BannerCard(
                  slide: slides[index],
                  onAction: () => _handleAction(slides[index]),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(slides.length, (index) {
            final active = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// BANNER CARD
// --------------------------------------------------

class _BannerCard extends StatelessWidget {
  final _BannerSlide slide;
  final VoidCallback onAction;

  const _BannerCard({required this.slide, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAction, // tapping anywhere on the banner works too
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(
            image: NetworkImage(slide.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 28, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(0.78),
                Colors.black.withOpacity(0.18),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // elegant serif italic eyebrow line
              Text(slide.titleTop, style: AppTextStyles.decorative),
              const SizedBox(height: 4),
              // bold modern sans headline (serif + sans = classic pairing)
              Text(
                slide.titleBottom,
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 210,
                child: Text(
                  slide.subtitle,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    height: 1.45,
                  ),
                ),
              ),
              const Spacer(),
              _BannerButton(label: slide.buttonText, onTap: onAction),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// BANNER BUTTON (press feedback + navigation)
// --------------------------------------------------

class _BannerButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _BannerButton({required this.label, required this.onTap});

  @override
  State<_BannerButton> createState() => _BannerButtonState();
}

class _BannerButtonState extends State<_BannerButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.button.copyWith(letterSpacing: 0.8),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}
