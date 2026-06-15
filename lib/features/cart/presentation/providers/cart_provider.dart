import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../../shop/domain/entities/product.dart';
import '../../../../core/services/storage_service.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    _loadFromStorage();
    return [];
  }

  Future<void> _loadFromStorage() async {
    try {
      final jsonStr = await StorageService.read('cart');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        state = list.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Failed to load cart: $e');
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final jsonStr = jsonEncode(state.map((item) => item.toJson()).toList());
      await StorageService.write('cart', jsonStr);
    } catch (e) {
      debugPrint('Failed to save cart: $e');
    }
  }

  void addProduct(Product product, String size) {
    if (product.stockPerSize[size] == null || product.stockPerSize[size]! <= 0) return;

    final newState = [...state];
    final index = newState.indexWhere((item) => item.product.id == product.id && item.selectedSize == size);
    if (index != -1) {
      if (newState[index].quantity < product.stockPerSize[size]!) {
        newState[index].quantity += 1;
      }
    } else {
      newState.add(CartItem(product: product, selectedSize: size));
    }
    state = newState;
    _saveToStorage();
  }

  void removeProduct(String productId, String size) {
    state = state.where((item) => !(item.product.id == productId && item.selectedSize == size)).toList();
    _saveToStorage();
  }
  
  void updateQuantity(String productId, String size, int quantity) {
     if (quantity <= 0) {
        removeProduct(productId, size);
        return;
     }
     final newState = [...state];
     final index = newState.indexWhere((item) => item.product.id == productId && item.selectedSize == size);
     if (index != -1) {
        final availableStock = newState[index].product.stockPerSize[size] ?? 0;
        newState[index].quantity = quantity > availableStock ? availableStock : quantity;
     }
     state = newState;
     _saveToStorage();
  }

  void clearCart() {
    state = [];
    _saveToStorage();
  }

  double get totalPrice {
    return state.fold(0, (total, item) => total + (item.product.price * item.quantity));
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});
