import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values.toList());

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.lineTotal);

  bool get isEmpty => _items.isEmpty;

  bool containsProduct(int productId) => _items.containsKey(productId);

  int quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity++;
    } else {
      _items[product.id] = CartItem(product: product);
    }
    notifyListeners();
  }

  void increaseQuantity(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(int productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity <= 1) {
      removeFromCart(productId);
    } else {
      _items[productId]!.quantity--;
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}