import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/food_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get deliveryFee => _items.isEmpty ? 0 : 40;
  double get discount => subtotal > 500 ? 50 : 0;
  double get total => subtotal + deliveryFee - discount;

  void addItem(FoodItem foodItem) {
    final index = _items.indexWhere((e) => e.foodItem.id == foodItem.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(foodItem: foodItem));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((e) => e.foodItem.id == id);
    notifyListeners();
  }

  void increment(String id) {
    final index = _items.indexWhere((e) => e.foodItem.id == id);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrement(String id) {
    final index = _items.indexWhere((e) => e.foodItem.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  bool isInCart(String id) => _items.any((e) => e.foodItem.id == id);

  int quantityOf(String id) {
    final index = _items.indexWhere((e) => e.foodItem.id == id);
    return index >= 0 ? _items[index].quantity : 0;
  }
}