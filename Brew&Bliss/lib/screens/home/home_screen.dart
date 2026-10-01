import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

import '../../widgets/search_bar.dart';
import '../../widgets/promo_banner.dart';
import '../../widgets/category_item.dart';
import '../../widgets/product_card.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/fade_slide_in.dart';
import '../../utils/page_transitions.dart';
import '../../data/products.dart';
import '../../models/wishlist_model.dart';

import '../cart/cart_screen.dart';
import '../notifications/notifications_screen.dart';
import '../products/all_products_screen.dart';
import '../products/product_detail_screen.dart';
import '../rewards/reward_screen.dart';
import '../addresses/addresses_screen.dart';
import '../search/search_screen.dart' show SettingsScreen;

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onTabSelected;

  const HomeScreen({super.key, this.onTabSelected});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _CategoryData {
  final IconData icon;
  final String title;

  const _CategoryData(this.icon, this.title);
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  final ScrollController _scrollController = ScrollController();

  // Scroll position lives in notifiers so only the tiny widgets that care
  // (header shadow, banner parallax) rebuild while scrolling - not the whole
  // screen on every frame.
  final ValueNotifier<double> _parallax = ValueNotifier(0);
  final ValueNotifier<bool> _headerElevated = ValueNotifier(false);

  // Skeleton is shown while the home content "loads" (first open + refresh).
  bool _isLoading = true;
  int _selectedCategory = 0;

  bool _cartPressed = false;
  bool _bellPressed = false;

  // ==========================================================
  // WISHLIST
  // ==========================================================

  final WishlistModel _wishlist = WishlistModel.instance;

  // ==========================================================
  // COFFEE CATEGORIES
  // ==========================================================

  final _categories = const [
    _CategoryData(Icons.apps, 'All'),
    _CategoryData(Icons.local_cafe_outlined, 'Latte'),
    _CategoryData(Icons.coffee, 'Cappuccino'),
    _CategoryData(Icons.coffee_outlined, 'Espresso'),
    _CategoryData(Icons.local_cafe, 'Americano'),
    _CategoryData(Icons.local_drink_outlined, 'Mocha'),
    _CategoryData(Icons.emoji_food_beverage_outlined, 'Macchiato'),
    _CategoryData(Icons.coffee_maker_outlined, 'Flat White'),
    _CategoryData(Icons.ac_unit_outlined, 'Cold Brew'),
  ];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      final elevated = offset > 8;
      if (_headerElevated.value != elevated) _headerElevated.value = elevated;
      _parallax.value = (offset * 0.35).clamp(0.0, 40.0);
    });

    _loadContent();
  }

  // [replay] re-runs the entrance animation (used by pull-to-refresh only;
  // on first open the page has already animated in around the skeleton).
  Future<void> _loadContent({bool replay = false}) async {
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (replay) {
      _entranceController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _parallax.dispose();
    _headerElevated.dispose();
    super.dispose();
  }

  // ==========================================================
  // DRAWER NAVIGATION
  // ==========================================================

  void _onDrawerItemSelected(int index) {
    switch (index) {
      case 0: // Home: already yahin ho
        break;
      case 1: // Menu tab
        widget.onTabSelected?.call(1);
        break;
      case 2: // My Orders tab
        widget.onTabSelected?.call(2);
        break;
      case 3: // Favorites tab
        widget.onTabSelected?.call(3);
        break;
      case 4: // Rewards (separate screen now)
        Navigator.push(context, slideTransition(const RewardsScreen()));
        break;
      case 5: // My Addresses
        Navigator.push(context, slideTransition(const AddressesScreen()));
        break;
      case 6: // Notifications
        Navigator.push(context, slideTransition(const NotificationsScreen()));
        break;
      case 7: // Settings
        Navigator.push(context, slideTransition(const SettingsScreen()));
        break;
    }
  }

  // ==========================================================
  // STAGGERED ANIMATION
  // ==========================================================

  Widget _staggered(
    Widget child, {
    required double start,
    required double end,
  }) {
    final animation = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(
        start,
        end,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              (1 - animation.value) * 24,
            ),
            child: child,
          ),
        );
      },
    );
  }

  // ==========================================================
  // REFRESH
  // ==========================================================

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();

    setState(() => _isLoading = true);
    await _loadContent(replay: true);
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isWide = width >= 600;

    final horizontalPadding = width < 340 ? 14.0 : 18.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: AppDrawer(
        selectedIndex: 0,
        onItemSelected: _onDrawerItemSelected,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            ValueListenableBuilder<bool>(
              valueListenable: _headerElevated,
              builder: (context, elevated, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: elevated
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: child,
                );
              },
              child: _staggered(
                _buildHeader(horizontalPadding),
                start: 0.0,
                end: 0.4,
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _onRefresh,
                // VIRTUALIZED body: a sliver list builds a section only when
                // it is about to scroll into view (+ a small cache), instead of
                // building the whole page up-front like a Column would.
                child: CustomScrollView(
                  controller: _scrollController,
                  cacheExtent: 200,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _KeepAliveSection(
                            key: ValueKey('home_section_$index'),
                            child: _buildSection(
                              index,
                              horizontalPadding,
                              isWide,
                            ),
                          ),
                          childCount: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // SECTIONS (built lazily by the sliver list in build())
  // ==========================================================

  Widget _buildSection(int index, double horizontalPadding, bool isWide) {
    switch (index) {
      // SEARCH BAR
      case 0:
        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: _staggered(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: AppSearchBar(onChanged: (_) {}),
            ),
            start: 0.05,
            end: 0.45,
          ),
        );

      // PROMO BANNER
      case 1:
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: _staggered(
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: ValueListenableBuilder<double>(
                valueListenable: _parallax,
                child: PromoBanner(
                  onOpenMenu: () => widget.onTabSelected?.call(1),
                ),
                builder: (context, parallax, child) {
                  return Transform.translate(
                    offset: Offset(0, -parallax * 0.15),
                    child: child,
                  );
                },
              ),
            ),
            start: 0.12,
            end: 0.55,
          ),
        );

      // COFFEE CATEGORIES
      case 2:
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: _staggered(
            _isLoading
                ? CategoryRowSkeleton(horizontalPadding: horizontalPadding)
                : _buildCategories(horizontalPadding),
            start: 0.2,
            end: 0.65,
          ),
        );

      // POPULAR COFFEES
      case 3:
        return Padding(
          padding: const EdgeInsets.only(top: 22),
          child: _staggered(
            _isLoading
                ? PopularStripSkeleton(horizontalPadding: horizontalPadding)
                : _buildPopularProducts(horizontalPadding, isWide),
            start: 0.3,
            end: 0.8,
          ),
        );

      // OFFER BANNER - below the fold, so it is only built (and its image
      // only requested) once the user scrolls close to it. Fades in.
      default:
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: FadeSlideIn(
            child: _buildOfferBanner(horizontalPadding),
          ),
        );
    }
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        10,
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  size: 28,
                  color: AppColors.darkBrown,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  shape: const CircleBorder(),
                  fixedSize: const Size(42, 42),
                ),
              );
            },
          ),
          const Spacer(),
          Column(
            children: [
              const Icon(
                Icons.coffee,
                color: AppColors.primary,
                size: 20,
              ),
              Text(
                'Brew & Bliss',
                style: AppTextStyles.logo.copyWith(
                  fontSize: 24,
                ),
              ),
              Text(
                '—  COFFEE HOUSE  —',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 7,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          _bounceIcon(
            icon: Icons.notifications_none,
            badge: '3',
            pressed: _bellPressed,
            onTapDown: () {
              setState(() {
                _bellPressed = true;
              });
            },
            onTapUp: () {
              setState(() {
                _bellPressed = false;
              });
            },
            onTap: () {
              Navigator.push(
                context,
                slideTransition(
                  const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 17),
          _bounceIcon(
            icon: Icons.shopping_cart_outlined,
            badge: '2',
            pressed: _cartPressed,
            onTapDown: () {
              setState(() {
                _cartPressed = true;
              });
            },
            onTapUp: () {
              setState(() {
                _cartPressed = false;
              });
            },
            onTap: () {
              Navigator.push(
                context,
                slideTransition(
                  const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER ICON
  // ==========================================================

  Widget _bounceIcon({
    required IconData icon,
    required String badge,
    required bool pressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) {
        HapticFeedback.selectionClick();
        onTapDown();
      },
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      child: AnimatedScale(
        scale: pressed ? 0.82 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              size: 29,
              color: AppColors.darkBrown,
            ),
            Positioned(
              right: -4,
              top: -5,
              child: _badge(badge),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BADGE
  // ==========================================================

  Widget _badge(String value) {
    return Container(
      width: 17,
      height: 17,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==========================================================
  // COFFEE CATEGORIES
  // ==========================================================

  Widget _buildCategories(double horizontalPadding) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: 10);
        },
        itemBuilder: (context, index) {
          final category = _categories[index];

          return _PopIn(
            delay: Duration(
              milliseconds: 30 * (index < 5 ? index : 0),
            ),
            child: CategoryItem(
              icon: category.icon,
              title: category.title,
              selected: _selectedCategory == index,
              onTap: () {
                HapticFeedback.selectionClick();

                setState(() {
                  _selectedCategory = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // WISHLIST HEART OVERLAY
  // ==========================================================

  Widget _wishlistCard(ProductCard card) {
    return AnimatedBuilder(
      animation: _wishlist,
      builder: (context, _) {
        final isLiked = _wishlist.contains(card.name);

        return Stack(
          children: [
            card,
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _wishlist.toggle(card.name);
                },
                child: AnimatedScale(
                  scale: isLiked ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: isLiked ? Colors.red : AppColors.darkBrown,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // POPULAR COFFEES
  // ==========================================================

  Widget _buildPopularProducts(
    double horizontalPadding,
    bool isWide,
  ) {
    final selectedTitle = _categories[_selectedCategory].title;

    // All -> popular coffees, otherwise every coffee of that category
    final products = _selectedCategory == 0
        ? popularProducts
        : allProducts.where((p) => p.category == selectedTitle).toList();

    final coffees = products
        .map(
          (p) => ProductCard.fromProduct(
            p,
            onTap: () => ProductDetailScreen.open(context, p),
          ),
        )
        .toList();

    return Column(
      children: [
        // SECTION TITLE
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Coffees',
                style: AppTextStyles.sectionTitle,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    slideTransition(
                      const AllProductsScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // COFFEE CARDS
        coffees.isEmpty
            ? _buildEmptyState(horizontalPadding)
            : isWide
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (int i = 0; i < coffees.length; i++)
                          _PopIn(
                            key: ValueKey('${_selectedCategory}_$i'),
                            delay: Duration(
                              milliseconds: 40 * (i < 4 ? i : 0),
                            ),
                            child: _wishlistCard(coffees[i]),
                          ),
                      ],
                    ),
                  )
                : SizedBox(
                    height: 310,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      itemCount: coffees.length,
                      separatorBuilder: (_, __) {
                        return const SizedBox(width: 12);
                      },
                      itemBuilder: (context, index) {
                        return _PopIn(
                          key: ValueKey('${_selectedCategory}_$index'),
                          delay: Duration(
                            milliseconds: 40 * (index < 4 ? index : 0),
                          ),
                          child: _wishlistCard(coffees[index]),
                        );
                      },
                    ),
                  ),
      ],
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.coffee_outlined,
                size: 40,
                color: AppColors.primary,
              ),
              const SizedBox(height: 10),
              Text(
                'Coming soon',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // OFFER BANNER
  // ==========================================================

  Widget _buildOfferBanner(double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ),
      child: Container(
        width: double.infinity,
        height: 145,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                15,
                150,
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKEND SPECIAL',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.mediumBrown,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '20% OFF',
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 27,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  Text(
                    'On all coffee orders',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  _OrderNowButton(
                    onTap: () => widget.onTabSelected?.call(1),
                  ),
                ],
              ),
            ),

            // OFFER IMAGE
            Positioned(
              right: 8,
              top: 7,
              bottom: 7,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=500&q=85',
                  width: 135,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // DISCOUNT BADGE
            Positioned(
              right: 15,
              top: 13,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.08);

                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 14,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '20%\nOFF',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.button.copyWith(
                      fontSize: 11,
                      height: 1.1,
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
}

// ==========================================================
// ORDER NOW BUTTON
// ==========================================================

class _OrderNowButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _OrderNowButton({this.onTap});

  @override
  State<_OrderNowButton> createState() => _OrderNowButtonState();
}

class _OrderNowButtonState extends State<_OrderNowButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _pressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _pressed = false;
        });
      },
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'ORDER NOW  →',
            style: AppTextStyles.button.copyWith(
              fontSize: 9,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// POP-IN ANIMATION
// ==========================================================

class _PopIn extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _PopIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // no timer at all when there is no delay -> starts on the very next frame
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.92 + (_animation.value * 0.08),
            child: child,
          ),
        );
      },
    );
  }
}

// ==========================================================
// KEEP-ALIVE SECTION
// ==========================================================

/// Keeps a lazily built Home section alive after it has been built once, so
/// scrolling away and back doesn't rebuild it or reset its inner state
/// (e.g. the horizontal scroll position of the Popular Coffees list).
class _KeepAliveSection extends StatefulWidget {
  final Widget child;

  const _KeepAliveSection({super.key, required this.child});

  @override
  State<_KeepAliveSection> createState() => _KeepAliveSectionState();
}

class _KeepAliveSectionState extends State<_KeepAliveSection>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}