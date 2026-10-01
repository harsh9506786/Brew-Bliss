import 'package:flutter/foundation.dart';

// Shared favourites list (Home hearts, Detail heart, Favorites screen).
class WishlistModel extends ChangeNotifier {
  WishlistModel._();

  static final WishlistModel instance = WishlistModel._();

  final Set<String> _names = {};

  int get count => _names.length;

  bool contains(String name) => _names.contains(name);

  void toggle(String name) {
    if (!_names.remove(name)) {
      _names.add(name);
    }
    notifyListeners();
  }

  void remove(String name) {
    if (_names.remove(name)) {
      notifyListeners();
    }
  }

  void clear() {
    if (_names.isEmpty) return;
    _names.clear();
    notifyListeners();
  }
}
