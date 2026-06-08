import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../data/menu_data.dart';

class MenuProvider with ChangeNotifier {
  final List<FoodItem> _allItems = menuItems;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  String get selectedCategory => _selectedCategory;

  List<String> get categories => ['All', 'Pizza', 'Burger', 'Drinks', 'Desserts'];

  List<FoodItem> get filteredItems {
    return _allItems.where((item) {
      final matchCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchSearch = item.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}