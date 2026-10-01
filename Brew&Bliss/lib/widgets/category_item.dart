import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class CategoryItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback? onTap;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.title,
    this.selected = false,
    this.onTap,
  });

  @override
  State<CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<CategoryItem> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 76,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.selected ? AppColors.primary : AppColors.white,
                  border: widget.selected
                      ? null
                      : Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: widget.selected
                          ? AppColors.primary.withOpacity(0.35)
                          : Colors.black12,
                      blurRadius: widget.selected ? 12 : 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Icon(
                    widget.icon,
                    key: ValueKey(widget.selected),
                    size: 28,
                    color: widget.selected ? Colors.white : AppColors.darkBrown,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 10.5,
                  color: widget.selected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}