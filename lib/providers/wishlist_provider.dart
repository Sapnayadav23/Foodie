import 'package:flutter/material.dart';
import '../models/food_item.dart';

class WishlistProvider with ChangeNotifier {
  final List<FoodItem> _items = [];

  List<FoodItem> get items => List.unmodifiable(_items);

  bool isWishlisted(String id) => _items.any((e) => e.id == id);

  void toggle(FoodItem item) {
    if (isWishlisted(item.id)) {
      _items.removeWhere((e) => e.id == item.id);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}