import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/fade_slide_in.dart';

class _CartItem {
  final String image;
  final String name;
  final String description;
  final double price;
  int quantity;

  _CartItem({
    required this.image,
    required this.name,
    required this.description,
    required this.price,
    this.quantity = 1,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Demo cart contents so the screen has something to show. In a bigger
  // build this would come from a shared cart shared across Home/Menu.
  final List<_CartItem> _items = [
    _CartItem(
      image:
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?auto=format&fit=crop&w=600&q=85',
      name: 'Cappuccino',
      description: 'Smooth espresso with steamed milk',
      price: 249,
      quantity: 1,
    ),
    _CartItem(
      image:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=600&q=85',
      name: 'Caffe Latte',
      description: 'Smooth espresso blended with creamy milk',
      price: 279,
      quantity: 1,
    ),
  ];

  static const double _deliveryFee = 40;

  int get _itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get _subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  double get _total => _items.isEmpty ? 0 : _subtotal + _deliveryFee;

  void _changeQty(_CartItem item, int delta) {
    HapticFeedback.selectionClick();
    setState(() {
      item.quantity += delta;
      if (item.quantity <= 0) _items.remove(item);
    });
  }

  // true while the order is being "placed" (button shows a loader and
  // ignores extra taps, so the order can't be submitted twice)
  bool _placingOrder = false;

  Future<void> _checkout() async {
    if (_placingOrder) return;
    HapticFeedback.mediumImpact();
    setState(() => _placingOrder = true);

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Order placed! Track it from Orders 🎉'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() {
      _items.clear();
      _placingOrder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _items.isEmpty ? _buildEmptyState() : _buildList(),
            ),
            if (_items.isNotEmpty) _buildSummary(),
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
      padding: const EdgeInsets.fromLTRB(10, 6, 18, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.darkBrown),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Cart', style: AppTextStyles.heading),
                const SizedBox(height: 2),
                Text(
                  _items.isEmpty ? 'Your cart is empty' : '$_itemCount items',
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
  // LIST
  // --------------------------------------------------

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        return FadeSlideIn(
          index: index,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppNetworkImage(
                    url: item.image,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${item.price.toStringAsFixed(0)}',
                        style: AppTextStyles.price.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _quantityStepper(item),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _quantityStepper(_CartItem item) {
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
            onTap: () => _changeQty(item, -1),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(
                item.quantity == 1 ? Icons.delete_outline : Icons.remove,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedPopValue(
              value: '${item.quantity}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _changeQty(item, 1),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.add, color: Colors.white, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SUMMARY / CHECKOUT
  // --------------------------------------------------

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _summaryRow('Subtotal', _subtotal),
          const SizedBox(height: 6),
          _summaryRow('Delivery Fee', _deliveryFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.sectionTitle),
              Text(
                '₹${_total.toStringAsFixed(0)}',
                style: AppTextStyles.price.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _placingOrder ? null : _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _placingOrder
                    ? const AppLoader(
                        key: ValueKey('loading'),
                        size: 22,
                        color: Colors.white,
                      )
                    : Text(
                        'Checkout',
                        key: const ValueKey('label'),
                        style: AppTextStyles.button,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(
          '₹${value.toStringAsFixed(0)}',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 60, color: AppColors.mediumBrown),
            const SizedBox(height: 16),
            Text('Your cart is empty', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 6),
            Text(
              'Looks like you haven\'t added\nanything to your cart yet.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('Browse Menu', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}
