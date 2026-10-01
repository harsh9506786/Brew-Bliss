import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

// ==========================================================
// SHIMMER
// ==========================================================

/// Sweeps a soft highlight across every [SkeletonBox] inside [child].
///
/// Wrap a WHOLE skeleton layout in a single [Shimmer] (not one per box):
/// one animation controller drives all the boxes, so it stays cheap and
/// every placeholder shines in sync.
class Shimmer extends StatefulWidget {
  final Widget child;

  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _base = Color(0xFFEFE4D8);
  static const _highlight = Color(0xFFFAF4EC);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            final t = _controller.value;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [_base, _highlight, _base],
              stops: const [0.25, 0.5, 0.75],
              transform: _SlideGradient(t),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double t;

  const _SlideGradient(this.t);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // slides from -100% to +100% of the width
    return Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
  }
}

// ==========================================================
// BASIC SHAPES
// ==========================================================

/// A plain rounded placeholder. Always use inside a [Shimmer].
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final bool circle;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // must be opaque - the shimmer gradient is painted over it
        color: Colors.white,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

// ==========================================================
// READY-MADE SKELETONS
// ==========================================================

/// Home -> horizontal "Popular Coffees" card (same size as ProductCard).
/// The card shell is static; only the grey blocks inside shimmer.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: const Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: double.infinity, height: 145, radius: 0),
            Padding(
              padding: EdgeInsets.fromLTRB(11, 12, 11, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 110, height: 14),
                  SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 10),
                  SizedBox(height: 5),
                  SkeletonBox(width: 90, height: 10),
                  SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(width: 48, height: 16),
                      SkeletonBox(width: 32, height: 32, circle: true),
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
}

/// Home -> row of category circles.
class CategoryRowSkeleton extends StatelessWidget {
  final double horizontalPadding;

  const CategoryRowSkeleton({super.key, this.horizontalPadding = 18});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, __) => const Column(
            children: [
              SkeletonBox(width: 64, height: 64, radius: 20),
              SizedBox(height: 8),
              SkeletonBox(width: 44, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// Home -> the whole "Popular Coffees" strip.
class PopularStripSkeleton extends StatelessWidget {
  final double horizontalPadding;

  const PopularStripSkeleton({super.key, this.horizontalPadding = 18});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Shimmer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonBox(width: 130, height: 18),
                SkeletonBox(width: 56, height: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 310,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const Align(
              alignment: Alignment.topCenter,
              child: ProductCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Menu -> 2 column grid of card placeholders.
class MenuGridSkeleton extends StatelessWidget {
  final int count;

  const MenuGridSkeleton({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: count,
      itemBuilder: (_, __) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: const Shimmer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: SkeletonBox(width: double.infinity, radius: 0),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(12, 12, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 90, height: 13),
                      SizedBox(height: 8),
                      SkeletonBox(width: 40, height: 10),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonBox(width: 46, height: 15),
                          SkeletonBox(width: 30, height: 30, circle: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orders / any list -> thumbnail + two lines + chip.
class ListItemSkeleton extends StatelessWidget {
  final int count;

  const ListItemSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
      itemCount: count,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Shimmer(
          child: Row(
            children: [
              SkeletonBox(width: 56, height: 56, radius: 13),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140, height: 13),
                    SizedBox(height: 8),
                    SkeletonBox(width: 90, height: 10),
                  ],
                ),
              ),
              SkeletonBox(width: 62, height: 22, radius: 11),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// SMALL LOADERS
// ==========================================================

/// Coffee-brown spinner for buttons / short blocking waits.
class AppLoader extends StatelessWidget {
  final double size;
  final Color color;

  const AppLoader({
    super.key,
    this.size = 22,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2.4, color: color),
    );
  }
}