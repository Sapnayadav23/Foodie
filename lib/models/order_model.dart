import 'cart_item.dart';

class OrderModel {
  final String fullName;
  final String phone;
  final String address;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime placedAt;

  OrderModel({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.items,
    required this.totalAmount,
    required this.placedAt,
  });
}