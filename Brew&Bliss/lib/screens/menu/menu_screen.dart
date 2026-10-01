import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/products.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/fade_slide_in.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // 'All' + every coffee category straight from data/products.dart
  final List<String> categories = ['All', ...productCategories];

  String selectedCategory = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // itemName -> quantity in cart
  final Map<String, int> cart = {};

  // Single source of truth: same catalogue as Home / All Products.
  final List<Product> items = allProducts;

  // Skeleton is shown while the menu "loads" (first open + pull to refresh).
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted && !_isLoading) setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredItems {
    return items.where((item) {
      final matchesCategory =
          selectedCategory == 'All' || item.category == selectedCategory;
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get _cartCount => cart.values.fold(0, (a, b) => a + b);

  double get _cartTotal {
    double total = 0;
    cart.forEach((name, qty) {
      final item = items.firstWhere((i) => i.name == name);
      total += item.priceValue * qty;
    });
    return total;
  }

  void _changeQty(Product item, int delta) {
    setState(() {
      final current = cart[item.name] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        cart.remove(item.name);
      } else {
        cart[item.name] = next;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Whole page scrolls (title + search go away), but the
            // category chips stay pinned at the top - Blinkit style.
            RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 14),
                        _buildSearchField(),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate:
                        _PinnedChipsDelegate(child: _buildCategoryChips()),
                  ),
                  ..._buildGridSlivers(),
                ],
              ),
            ),
            if (_cartCount > 0) _buildCartBar(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Our Menu', style: AppTextStyles.heading),
                const SizedBox(height: 3),
                Text(
                  _isLoading
                      ? 'Loading menu...'
                      : '${_filteredItems.length} items available',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SEARCH
  // --------------------------------------------------

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => searchQuery = value),
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Search your favourite coffee...',
            hintStyle: AppTextStyles.bodySmall,
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.mediumBrown,
            ),
            suffixIcon: searchQuery.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.mediumBrown,
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // CATEGORY CHIPS
  // --------------------------------------------------

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == selectedCategory;

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                category,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // GRID
  // --------------------------------------------------

  List<Widget> _buildGridSlivers() {
    if (_isLoading) {
      return const [SliverToBoxAdapter(child: MenuGridSkeleton())];
    }

    final filtered = _filteredItems;

    if (filtered.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _buildEmptyState(),
        ),
      ];
    }

    return [
      SliverPadding(
        // Extra room only when the floating "View Cart" bar is visible
        padding: EdgeInsets.fromLTRB(18, 4, 18, _cartCount > 0 ? 110 : 20),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = filtered[index];
              return FadeSlideIn(
                key: ValueKey(item.name),
                index: index,
                child: _MenuCard(
                  item: item,
                  quantity: cart[item.name] ?? 0,
                  onTap: () => _openItemDetail(item),
                  onAdd: () => _changeQty(item, 1),
                  onRemove: () => _changeQty(item, -1),
                ),
              );
            },
            childCount: filtered.length,
          ),
        ),
      ),
    ];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 54,
            color: AppColors.mediumBrown,
          ),
          const SizedBox(height: 12),
          Text('No items found', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text(
            'Try a different search or category',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // ITEM DETAIL SHEET
  // --------------------------------------------------

  void _openItemDetail(Product item) {
    int qty = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12),
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AppNetworkImage(
                            url: item.image,
                            height: 190,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: AppTextStyles.heading.copyWith(
                                      fontSize: 21,
                                    ),
                                  ),
                                ),
                                Text(
                                  item.price,
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 17,
                                  color: Color(0xFFD18B22),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.rating}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${item.reviews})',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              style: AppTextStyles.body.copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Quantity',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Row(
                                  children: [
                                    _sheetStepperButton(
                                      icon: Icons.remove,
                                      onTap: () {
                                        if (qty > 1) {
                                          setSheetState(() => qty--);
                                        }
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        '$qty',
                                        style: AppTextStyles.sectionTitle,
                                      ),
                                    ),
                                    _sheetStepperButton(
                                      icon: Icons.add,
                                      onTap: () => setSheetState(() => qty++),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    cart[item.name] =
                                        (cart[item.name] ?? 0) + qty;
                                  });
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'Add ${qty > 1 ? '$qty items' : 'to Cart'}  •  ₹${(item.priceValue * qty).toStringAsFixed(0)}',
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 17, color: AppColors.darkBrown),
      ),
    );
  }

  // --------------------------------------------------
  // FLOATING CART BAR
  // --------------------------------------------------

  Widget _buildCartBar() {
    return Positioned(
      left: 18,
      right: 18,
      bottom: 16,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        offset: _cartCount > 0 ? Offset.zero : const Offset(0, 2),
        child: GestureDetector(
          onTap: _openCartSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedPopValue(
                    value: '$_cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'View Cart',
                    style: AppTextStyles.button.copyWith(fontSize: 13),
                  ),
                ),
                Text(
                  '₹${_cartTotal.toStringAsFixed(0)}',
                  style: AppTextStyles.button.copyWith(fontSize: 14),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final entries = cart.entries.toList();

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 6),
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Your Cart', style: AppTextStyles.sectionTitle),
                        Text(
                          '${entries.fold(0, (a, e) => a + e.value)} items',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Your cart is empty',
                        style: AppTextStyles.bodyMedium,
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final item =
                              items.firstWhere((i) => i.name == entry.key);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AppNetworkImage(
                                    url: item.image,
                                    width: 54,
                                    height: 54,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.price,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                _sheetStepperButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    _changeQty(item, -1);
                                    setSheetState(() {});
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Text(
                                    '${entry.value}',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                                _sheetStepperButton(
                                  icon: Icons.add,
                                  onTap: () {
                                    _changeQty(item, 1);
                                    setSheetState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  if (entries.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total', style: AppTextStyles.sectionTitle),
                              Text(
                                '₹${_cartTotal.toStringAsFixed(0)}',
                                style: AppTextStyles.price.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Order placed! Track it from Orders 🎉',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                setState(() => cart.clear());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                'Checkout',
                                style: AppTextStyles.button,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// --------------------------------------------------
// MENU CARD
// --------------------------------------------------

class _MenuCard extends StatelessWidget {
  final Product item;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuCard({
    required this.item,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final inCart = quantity > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: inCart ? AppColors.primary : AppColors.border,
            width: inCart ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  inCart ? AppColors.primary.withOpacity(0.18) : Colors.black12,
              blurRadius: inCart ? 10 : 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(18),
                  ),
                  child: AppNetworkImage(
                    url: item.image,
                    height: 108,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (item.isPopular)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'POPULAR',
                        style: AppTextStyles.button.copyWith(fontSize: 7),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: Color(0xFFD18B22),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${item.rating}',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.price,
                        style: AppTextStyles.price.copyWith(fontSize: 14),
                      ),
                      inCart ? _quantityStepper() : _addButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 17),
      ),
    );
  }

  Widget _quantityStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedPopValue(
              value: '$quantity',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// Pinned category chip bar (stays visible while scrolling)
// --------------------------------------------------

class _PinnedChipsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _PinnedChipsDelegate({required this.child});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        // soft shadow only once content scrolls underneath
        boxShadow: overlapsContent
            ? const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedChipsDelegate oldDelegate) => true;
}
