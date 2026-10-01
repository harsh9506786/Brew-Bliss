import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/products.dart';
import '../../models/cart_model.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/fade_slide_in.dart';
import '../../models/wishlist_model.dart';

class _SizeOption {
  final String label;
  final String oz;
  final double extra;

  const _SizeOption(this.label, this.oz, this.extra);
}

class _MilkOption {
  final String label;
  final double extra;

  const _MilkOption(this.label, this.extra);
}

class _ExtraOption {
  final String label;
  final double price;

  const _ExtraOption(this.label, this.price);
}

class ProductDetailScreen extends StatefulWidget {
  final String image;
  final String name;
  final String description;
  final String rating;
  final String reviews;
  final String price;

  const ProductDetailScreen({
    super.key,
    required this.image,
    required this.name,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.price,
  });

  // One place that opens the detail screen for any product
  static void open(BuildContext context, Product product) {
    Navigator.push(
      context,
      slideTransition(
        ProductDetailScreen(
          image: product.image,
          name: product.name,
          description: product.description,
          rating: product.rating,
          reviews: product.reviews,
          price: product.price,
        ),
      ),
    );
  }

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // ==========================================================
  // OPTIONS (prices in ₹)
  // ==========================================================

  static const _sizes = [
    _SizeOption('S', '6 oz', -30),
    _SizeOption('M', '12 oz', 0),
    _SizeOption('L', '16 oz', 40),
  ];

  static const _milks = [
    _MilkOption('Dairy Milk', 0),
    _MilkOption('Oat Milk', 40),
    _MilkOption('Almond Milk', 50),
  ];

  static const _extraOptions = [
    _ExtraOption('Extra Shot', 60),
    _ExtraOption('Vanilla Syrup', 40),
  ];

  int _size = 1;
  int _milk = 0;
  final Set<int> _extras = {};
  int _qty = 1;

  bool _liked = false;
  bool _added = false;

  // ==========================================================
  // PRICE
  // ==========================================================

  double get _basePrice {
    return double.tryParse(
          widget.price.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0;
  }

  double get _unitPrice {
    double price = _basePrice + _sizes[_size].extra + _milks[_milk].extra;

    for (final i in _extras) {
      price += _extraOptions[i].price;
    }

    return price;
  }

  double get _total => _unitPrice * _qty;

  String _money(double value) {
    return value == value.roundToDouble()
        ? '₹${value.toInt()}'
        : '₹${value.toStringAsFixed(2)}';
  }

  // ==========================================================
  // ADD TO CART
  // ==========================================================

  void _addToCart() {
    HapticFeedback.mediumImpact();

    final extraIndexes = _extras.toList()..sort();

    CartModel.instance.add(
      CartItem(
        name: widget.name,
        image: widget.image,
        size: _sizes[_size].label,
        milk: _milks[_milk].label,
        extras: extraIndexes.map((i) => _extraOptions[i].label).toList(),
        unitPrice: _unitPrice,
        quantity: _qty,
      ),
    );

    setState(() {
      _added = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${widget.name} added to cart'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.darkBrown,
          duration: const Duration(milliseconds: 1500),
        ),
      );

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _added = false;
        });
      }
    });
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = (size.height * 0.36).clamp(240.0, 340.0);
    final horizontalPadding = size.width < 340 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // IMAGE
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: imageHeight,
                  child: AppNetworkImage(
                    url: widget.image,
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),

                // DETAILS
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(top: imageHeight - 28),
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        22,
                        horizontalPadding,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitleRow(),
                          const SizedBox(height: 8),
                          _buildRatingRow(),
                          const SizedBox(height: 12),
                          Text(
                            widget.description,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _buildSizeSection(),
                          const SizedBox(height: 22),
                          _buildMilkSection(),
                          const SizedBox(height: 22),
                          _buildExtrasSection(),
                        ],
                      ),
                    ),
                  ),
                ),

                // BACK + HEART
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        _circleButton(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            size: 22,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        const Spacer(),
                        _circleButton(
                          onTap: () {
                            HapticFeedback.selectionClick();

                            setState(() {
                              _liked = !_liked;
                            });
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              _liked ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(_liked),
                              size: 22,
                              color: _liked ? Colors.red : AppColors.darkBrown,
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
          _buildBottomBar(horizontalPadding),
        ],
      ),
    );
  }

  // ==========================================================
  // TITLE + PRICE
  // ==========================================================

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            widget.name,
            style: AppTextStyles.heading.copyWith(
              fontSize: 26,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _money(_unitPrice),
          style: AppTextStyles.price.copyWith(fontSize: 22),
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        const Icon(
          Icons.star,
          size: 16,
          color: Color(0xFFD18B22),
        ),
        const SizedBox(width: 4),
        Text(
          widget.rating,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        ),
        const SizedBox(width: 4),
        Text(
          '(${widget.reviews} reviews)',
          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  // ==========================================================
  // SIZE
  // ==========================================================

  Widget _buildSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Size', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        Row(
          children: [
            for (int i = 0; i < _sizes.length; i++) ...[
              _choiceBox(
                selected: _size == i,
                width: 72,
                height: 64,
                onTap: () {
                  HapticFeedback.selectionClick();

                  setState(() {
                    _size = i;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _sizes[i].label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _size == i ? Colors.white : AppColors.darkBrown,
                      ),
                    ),
                    Text(
                      _sizes[i].oz,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10,
                        color: _size == i ? Colors.white70 : null,
                      ),
                    ),
                  ],
                ),
              ),
              if (i != _sizes.length - 1) const SizedBox(width: 12),
            ],
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // MILK
  // ==========================================================

  Widget _buildMilkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Milk', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (int i = 0; i < _milks.length; i++)
              _choiceBox(
                selected: _milk == i,
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                onTap: () {
                  HapticFeedback.selectionClick();

                  setState(() {
                    _milk = i;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _milks[i].label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                _milk == i ? Colors.white : AppColors.darkBrown,
                          ),
                        ),
                        if (_milk == i) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check,
                            size: 13,
                            color: Colors.white,
                          ),
                        ],
                      ],
                    ),
                    if (_milks[i].extra > 0)
                      Text(
                        '+${_money(_milks[i].extra)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10,
                          color: _milk == i ? Colors.white70 : null,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // EXTRAS
  // ==========================================================

  Widget _buildExtrasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add Extras', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 6),
        for (int i = 0; i < _extraOptions.length; i++)
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _toggleExtra(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _extraOptions[i].label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    '+ ${_money(_extraOptions[i].price)}',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _extras.contains(i),
                      activeColor: AppColors.darkBrown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onChanged: (_) => _toggleExtra(i),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _toggleExtra(int index) {
    HapticFeedback.selectionClick();

    setState(() {
      if (_extras.contains(index)) {
        _extras.remove(index);
      } else {
        _extras.add(index);
      }
    });
  }

  // ==========================================================
  // BOTTOM BAR
  // ==========================================================

  Widget _buildBottomBar(double horizontalPadding) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            12,
            horizontalPadding,
            12,
          ),
          child: Row(
            children: [
              // QUANTITY
              _qtyButton(
                icon: Icons.remove,
                onTap: _qty > 1
                    ? () {
                        HapticFeedback.selectionClick();

                        setState(() {
                          _qty--;
                        });
                      }
                    : null,
              ),
              SizedBox(
                width: 34,
                child: Text(
                  '$_qty',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              _qtyButton(
                icon: Icons.add,
                onTap: () {
                  HapticFeedback.selectionClick();

                  setState(() {
                    _qty++;
                  });
                },
              ),

              const SizedBox(width: 14),

              // ADD TO CART
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBrown,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Row(
                            key: ValueKey(_added),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_added) ...[
                                const Icon(Icons.check, size: 18),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                _added ? 'Added' : 'Add to Cart',
                                style: AppTextStyles.button.copyWith(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _money(_total),
                          style: AppTextStyles.button.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SMALL HELPERS
  // ==========================================================

  Widget _circleButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onTap == null
                ? AppColors.border
                : AppColors.darkBrown.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? AppColors.border : AppColors.darkBrown,
        ),
      ),
    );
  }

  Widget _choiceBox({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
    double? width,
    required double height,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: width,
        height: height,
        padding: padding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.darkBrown : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.darkBrown : AppColors.border,
          ),
        ),
        child: child,
      ),
    );
  }
}
