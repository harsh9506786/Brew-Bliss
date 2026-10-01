import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final String image;
  final String size;
  final String milk;
  final List<String> extras;
  final double unitPrice;
  int quantity;

  CartItem({
    required this.name,
    required this.image,
    required this.size,
    required this.milk,
    required this.extras,
    required this.unitPrice,
    this.quantity = 1,
  });

  double get total => unitPrice * quantity;

  // Same coffee + same options = same cart line
  bool isSameAs(CartItem other) {
    return name == other.name &&
        size == other.size &&
        milk == other.milk &&
        listEquals(extras, other.extras);
  }
}

class CartModel extends ChangeNotifier {
  CartModel._();

  static final CartModel instance = CartModel._();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.total);

  void add(CartItem item) {
    final index = _items.indexWhere((e) => e.isSameAs(item));

    if (index == -1) {
      _items.add(item);
    } else {
      _items[index].quantity += item.quantity;
    }

    notifyListeners();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity < 1) {
      remove(index);
      return;
    }

    _items[index].quantity = quantity;
    notifyListeners();
  }

  void remove(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
