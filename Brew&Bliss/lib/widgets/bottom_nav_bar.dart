import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  // Sonar-style pulse ring around the center "Order" button. Only runs
  // while that tab is the active one, so it reads as a status glow
  // rather than a constant distraction.
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.currentIndex == 2) _ringController.repeat();
  }

  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isOrderSelected = widget.currentIndex == 2;
    final wasOrderSelected = oldWidget.currentIndex == 2;
    if (isOrderSelected && !wasOrderSelected) {
      _ringController.repeat();
    } else if (!isOrderSelected && wasOrderSelected) {
      _ringController.stop();
      _ringController.reset();
    }
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index != widget.currentIndex) HapticFeedback.selectionClick();
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    // Floating rounded + bordered bar, inset from the screen edges —
    // the pill-shaped bottom nav style seen on apps like Flipkart,
    // rather than a flat edge-to-edge strip. clipBehavior stays at
    // Clip.none (the Container default) so the raised Order button can
    // still poke out above the rounded top edge.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _NavItem(
              selected: widget.currentIndex == 0,
              icon: Icons.home_outlined,
              selectedIcon: Icons.home,
              label: 'Home',
              onTap: () => _select(0),
            ),
            _NavItem(
              selected: widget.currentIndex == 1,
              icon: Icons.menu_book_outlined,
              selectedIcon: Icons.menu_book,
              label: 'Menu',
              onTap: () => _select(1),
            ),
            _buildOrderItem(),
            _NavItem(
              selected: widget.currentIndex == 3,
              icon: Icons.favorite_border,
              selectedIcon: Icons.favorite,
              label: 'Favorites',
              onTap: () => _select(3),
            ),
            _NavItem(
              selected: widget.currentIndex == 4,
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Profile',
              onTap: () => _select(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem() {
    final selected = widget.currentIndex == 2;

    return Expanded(
      child: _OrderTabButton(
        selected: selected,
        onTap: () => _select(2),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (selected)
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (context, child) {
                      final t = _ringController.value;
                      return Transform.translate(
                        offset: const Offset(0, -19),
                        child: Opacity(
                          opacity: (1 - t).clamp(0.0, 1.0) * 0.45,
                          child: Transform.scale(
                            scale: 1 + t * 0.6,
                            child: Container(
                              width: 57,
                              height: 57,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: selected ? 1.08 : 1.0),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) => Transform.translate(
                    offset: const Offset(0, -19),
                    child: Transform.scale(scale: scale, child: child),
                  ),
                  child: Container(
                    width: 57,
                    height: 57,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.coffee, color: Colors.white, size: 27),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -11),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: selected
                    ? AppTextStyles.navLabelSelected
                    : AppTextStyles.navLabel,
                child: const Text('Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Regular icon + label tab (Home, Menu, Rewards, Profile).
// --------------------------------------------------

class _NavItem extends StatefulWidget {
  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer keeps icon/label vertically aligned with the
              // raised Order button (the old pill indicator is removed).
              const SizedBox(height: 9),
              // Selected icon lifts slightly and swaps outline -> filled
              // with a soft fade + pop instead of an instant snap.
              AnimatedSlide(
                offset: widget.selected ? const Offset(0, -0.12) : Offset.zero,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    widget.selected ? widget.selectedIcon : widget.icon,
                    key: ValueKey(widget.selected),
                    size: 24,
                    color: widget.selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: widget.selected
                    ? AppTextStyles.navLabelSelected
                    : AppTextStyles.navLabel,
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Center raised "Order" button.
// --------------------------------------------------

class _OrderTabButton extends StatefulWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _OrderTabButton({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  State<_OrderTabButton> createState() => _OrderTabButtonState();
}

class _OrderTabButtonState extends State<_OrderTabButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
