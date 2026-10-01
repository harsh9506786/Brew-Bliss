import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'skeleton.dart';

/// Drop-in replacement for [Image.network].
///
///  * shows a shimmer placeholder while the image downloads
///  * fades the image in once it is ready (no sudden pop)
///  * decodes the image at the size it is actually drawn (cacheWidth),
///    which saves a lot of memory on lists / grids
///  * shows a clean icon fallback instead of the red broken-image box
class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.coffee_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.of(context).devicePixelRatio;

        // width we will really paint at (explicit, else parent's max)
        double? drawWidth = width;
        if (drawWidth == null || !drawWidth.isFinite) {
          drawWidth =
              constraints.maxWidth.isFinite ? constraints.maxWidth : null;
        }
        final int? cacheWidth =
            drawWidth == null ? null : (drawWidth * dpr).round();

        return Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          cacheWidth: cacheWidth,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              child: child,
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder();
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: AppColors.cream,
              alignment: Alignment.center,
              child: Icon(
                fallbackIcon,
                color: AppColors.mediumBrown,
                size: ((height ?? 80) * 0.32).clamp(18.0, 48.0),
              ),
            );
          },
        );
      },
    );
  }

  Widget _placeholder() {
    return Shimmer(
      child: SkeletonBox(width: width, height: height, radius: 0),
    );
  }
}

/// Wraps [child] with a subtle fade + upward slide entrance animation.
/// Pass an increasing [index] for staggered list/grid animations.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration delayStep;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.delayStep = const Duration(milliseconds: 45),
  });

  @override
  Widget build(BuildContext context) {
    // Stagger only the first few items; later ones (usually offscreen or
    // far down the list) animate at the same quick speed instead of taking
    // longer and longer to appear.
    final duration = Duration(
      milliseconds: 240 + (index.clamp(0, 5) * 35),
    );

    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, childWidget) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

/// A number that "pops" with a scale + fade whenever its value changes.
class AnimatedPopValue extends StatelessWidget {
  final String value;
  final TextStyle? style;

  const AnimatedPopValue({super.key, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.6, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
      child: Text(
        value,
        key: ValueKey(value),
        style: style,
      ),
    );
  }
}

/// Counts up from 0 to [value] once, on first build.
class CountUpText extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return Text('$v$suffix', style: style);
      },
    );
  }
}
