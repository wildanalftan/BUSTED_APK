import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';

class ProductsNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() {
    _loadProducts();
    return [];
  }

  Future<void> _loadProducts() async {
    FirebaseFirestore.instance.collection('products').snapshots().listen((snapshot) {
      final products = snapshot.docs.map((doc) {
        return Product.fromJson(doc.data());
      }).toList();
      state = products;
    });
  }

  Future<void> addProduct(Product product) async {
    await FirebaseFirestore.instance.collection('products').doc(product.id).set(product.toJson());
  }

  Future<void> removeProduct(String id) async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }

  Future<void> updateProduct(Product updatedProduct) async {
    await FirebaseFirestore.instance.collection('products').doc(updatedProduct.id).set(updatedProduct.toJson());
  }

  Future<void> reduceStock(String productId, String size, int amount) async {
    final docRef = FirebaseFirestore.instance.collection('products').doc(productId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final product = Product.fromJson(snapshot.data()!);
      final newStock = Map<String, int>.from(product.stockPerSize);
      if (newStock.containsKey(size)) {
         newStock[size] = (newStock[size]! - amount).clamp(0, 9999);
      }
      transaction.update(docRef, {'stockPerSize': newStock});
    });
  }

  Future<void> increaseStock(String productId, String size, int amount) async {
    final docRef = FirebaseFirestore.instance.collection('products').doc(productId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final product = Product.fromJson(snapshot.data()!);
      final newStock = Map<String, int>.from(product.stockPerSize);
      if (newStock.containsKey(size)) {
         newStock[size] = (newStock[size]! + amount).clamp(0, 9999);
      }
      transaction.update(docRef, {'stockPerSize': newStock});
    });
  }
}

final productsProvider = NotifierProvider<ProductsNotifier, List<Product>>(() {
  return ProductsNotifier();
});
