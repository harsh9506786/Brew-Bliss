import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    this.selectedIndex = 0,
    required this.onItemSelected,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  int? pressedIndex;
  bool _logoutPressed = false;
  bool _closePressed = false;

  late final AnimationController _controller;

  final List<_DrawerItem> mainItems = const [
    _DrawerItem(
      icon: Icons.home_rounded,
      title: 'Home',
      subtitle: 'Discover your favorites',
    ),
    _DrawerItem(
      icon: Icons.local_cafe_rounded,
      title: 'Menu',
      subtitle: 'Explore our coffee menu',
    ),
    _DrawerItem(
      icon: Icons.receipt_long_rounded,
      title: 'My Orders',
      subtitle: 'Track your recent orders',
    ),
    _DrawerItem(
      icon: Icons.favorite_rounded,
      title: 'Favorites',
      subtitle: 'Your saved favorites',
    ),
    _DrawerItem(
      icon: Icons.card_giftcard_rounded,
      title: 'Rewards',
      subtitle: 'Earn points & redeem rewards',
    ),
  ];

  final List<_DrawerItem> otherItems = const [
    _DrawerItem(
      icon: Icons.location_on_rounded,
      title: 'My Addresses',
      subtitle: 'Manage delivery locations',
    ),
    _DrawerItem(
      icon: Icons.notifications_rounded,
      title: 'Notifications',
      subtitle: 'Offers & order updates',
    ),
    _DrawerItem(
      icon: Icons.settings_rounded,
      title: 'Settings',
      subtitle: 'Preferences & account',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }

  // Fade + slide-in wrapper, staggered by [start]-[end] over the entrance
  // controller. Used for every block so the whole drawer animates in
  // together instead of just appearing.
  Widget _staggered(Widget child,
      {required double start, required double end}) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset((1 - animation.value) * -26, 0),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.84,
      backgroundColor: AppColors.background,
      elevation: 0,
      // top: false -> the brown header extends behind the status bar and
      // scrolls away together with the list (whole drawer scrolls).
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _staggered(_sectionTitle('EXPLORE'),
                        start: 0.15, end: 0.45),
                    const SizedBox(height: 8),
                    ...List.generate(
                      mainItems.length,
                      (index) => _staggered(
                        _buildMenuItem(item: mainItems[index], index: index),
                        start: 0.15 + (index * 0.05),
                        end: 0.55 + (index * 0.05),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _staggered(_buildRewardCard(), start: 0.45, end: 0.85),
                    const SizedBox(height: 24),
                    _staggered(_sectionTitle('ACCOUNT'), start: 0.5, end: 0.8),
                    const SizedBox(height: 8),
                    ...List.generate(
                      otherItems.length,
                      (index) => _staggered(
                        _buildMenuItem(
                          item: otherItems[index],
                          index: index + mainItems.length,
                        ),
                        start: 0.5 + (index * 0.05),
                        end: 0.85 + (index * 0.05),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: AppColors.mediumBrown.withOpacity(0.2)),
                    const SizedBox(height: 6),
                    _staggered(_buildLogout(), start: 0.7, end: 1.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader() {
    return Container(
      // extra top padding = status bar height, since SafeArea(top: false)
      padding: EdgeInsets.fromLTRB(
          22, 20 + MediaQuery.of(context).padding.top, 18, 22),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Decorative background blobs — pure static styling, no logic.
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    _staggered(
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          size: 29,
                          color: AppColors.primary,
                        ),
                      ),
                      start: 0.0,
                      end: 0.4,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _staggered(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.82),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Harshvardhan',
                              style: AppTextStyles.heading.copyWith(
                                color: Colors.white,
                                fontSize: 21,
                              ),
                            ),
                          ],
                        ),
                        start: 0.05,
                        end: 0.45,
                      ),
                    ),
                    GestureDetector(
                      onTapDown: (_) => setState(() => _closePressed = true),
                      onTapUp: (_) => setState(() => _closePressed = false),
                      onTapCancel: () => setState(() => _closePressed = false),
                      onTap: () => Navigator.pop(context),
                      child: AnimatedRotation(
                        turns: _closePressed ? 0.08 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: AnimatedScale(
                          scale: _closePressed ? 0.85 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _staggered(
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.coffee_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your daily coffee ritual awaits',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                  start: 0.15,
                  end: 0.55,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // SECTION TITLE
  // --------------------------------------------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.mediumBrown,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // --------------------------------------------------
  // MENU ITEM
  // --------------------------------------------------

  Widget _buildMenuItem({
    required _DrawerItem item,
    required int index,
  }) {
    final bool selected = widget.selectedIndex == index;
    final bool pressed = pressedIndex == index;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        setState(() => pressedIndex = index);
      },
      onTapCancel: () => setState(() => pressedIndex = null),
      onTap: () {
        setState(() => pressedIndex = null);
        Navigator.pop(context);
        widget.onItemSelected(index);
      },
      child: AnimatedScale(
        scale: pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.10)
                : pressed
                    ? AppColors.cream
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.cream,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: AnimatedRotation(
                  turns: selected ? 0.02 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    item.icon,
                    size: 21,
                    color: selected ? Colors.white : AppColors.darkBrown,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            selected ? AppColors.primary : AppColors.darkBrown,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumBrown,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // REWARD CARD
  // --------------------------------------------------

  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mediumBrown.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stars_rounded,
                    color: Colors.white, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Coffee Rewards',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              Text(
                '320 pts',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            '80 points away from a free coffee',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 8),
          // Progress bar fills up from 0 -> 0.80 once the drawer opens,
          // instead of just appearing already-full.
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 0.80),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 7,
                backgroundColor: Colors.white,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // LOGOUT — now part of the scrollable content, not a fixed footer.
  // --------------------------------------------------

  Widget _buildLogout() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _logoutPressed = true),
      onTapUp: (_) => setState(() => _logoutPressed = false),
      onTapCancel: () => setState(() => _logoutPressed = false),
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.background,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Log out?', style: AppTextStyles.sectionTitle),
            content: Text(
              'You\'ll need to sign in again to place orders.',
              style: AppTextStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Logout', style: AppTextStyles.button),
              ),
            ],
          ),
        );

        if (confirm != true || !mounted) return;

        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context); // drawer band
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: AnimatedScale(
        scale: _logoutPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: _logoutPressed
                ? Colors.red.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.redAccent, size: 20),
              ),
              const SizedBox(width: 13),
              Text(
                'Logout',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// DRAWER ITEM MODEL
// --------------------------------------------------

class _DrawerItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
