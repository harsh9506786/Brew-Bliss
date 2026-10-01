import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/products.dart';
import '../../models/wishlist_model.dart';
import '../../widgets/fade_slide_in.dart';
import '../products/product_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  // false when shown as a bottom-nav tab (nothing to go back to)
  final bool showBackButton;

  const FavoritesScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistModel.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: wishlist,
          builder: (context, _) {
            final favorites =
                allProducts.where((p) => wishlist.contains(p.name)).toList();

            return Column(
              children: [
                _buildHeader(context, favorites.length, wishlist),
                Expanded(
                  child: favorites.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                          itemCount: favorites.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return FadeSlideIn(
                              index: index,
                              child: _buildTile(
                                  context, favorites[index], wishlist),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count, WishlistModel wishlist) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 14, 0),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.darkBrown),
            ),
            const SizedBox(width: 4),
          ] else
            const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Favorites', style: AppTextStyles.heading),
                const SizedBox(height: 2),
                Text(
                  count == 0 ? 'Nothing saved yet' : '$count saved items',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (count > 0)
            TextButton(
              onPressed: wishlist.clear,
              child: Text(
                'Clear all',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, Product product, WishlistModel wishlist) {
    return GestureDetector(
      onTap: () => ProductDetailScreen.open(context, product),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AppNetworkImage(
                url: product.image,
                width: 78,
                height: 78,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 3),
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 15, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(product.rating, style: AppTextStyles.bodySmall),
                      const Spacer(),
                      Text(product.price, style: AppTextStyles.price),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => wishlist.remove(product.name),
              icon: const Icon(Icons.favorite, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('No favorites yet', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text('Tap the heart on any coffee to save it here',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
