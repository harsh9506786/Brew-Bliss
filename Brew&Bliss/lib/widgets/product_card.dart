import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../data/products.dart';
import 'fade_slide_in.dart';

class ProductCard extends StatefulWidget {
  final String image;
  final String name;
  final String description;
  final String rating;
  final String reviews;
  final String price;
  final String category;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.price,
    this.category = '',
    this.onTap,
  });

  // Build a card straight from the shared catalogue
  factory ProductCard.fromProduct(
    Product product, {
    VoidCallback? onTap,
  }) {
    return ProductCard(
      image: product.image,
      name: product.name,
      description: product.description,
      rating: product.rating,
      reviews: product.reviews,
      price: product.price,
      category: product.category,
      onTap: onTap,
    );
  }

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;
  bool _added = false;

  void _toggleAdd() {
    HapticFeedback.lightImpact();
    setState(() => _added = !_added);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 180,
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color:
                    _pressed ? Colors.black12 : Colors.black.withOpacity(0.08),
                blurRadius: _pressed ? 4 : 10,
                offset: Offset(0, _pressed ? 1 : 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Coffee Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(17),
                ),
                child: AppNetworkImage(
                  url: widget.image,
                  height: 145,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Coffee Details
              Padding(
                padding: const EdgeInsets.fromLTRB(11, 10, 10, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9.5,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 15,
                          color: Color(0xFFD18B22),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.rating,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '(${widget.reviews})',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Price + Add Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.price,
                          style: AppTextStyles.price,
                        ),
                        GestureDetector(
                          onTap: _toggleAdd,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutBack,
                            width: 31,
                            height: 31,
                            decoration: BoxDecoration(
                              color: _added
                                  ? AppColors.darkBrown
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: _added
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, animation) {
                                return RotationTransition(
                                  turns: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                _added ? Icons.check : Icons.add,
                                key: ValueKey(_added),
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
