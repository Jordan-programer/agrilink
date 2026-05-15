import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

class CartProvider extends ChangeNotifier {
  static const _storageKey = 'agrilink_cart_v1';

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get totalItems => _items.length;

  double get totalAoa => _items.fold(0, (sum, i) => sum + i.subtotal);

  bool get isEmpty => _items.isEmpty;

  /// Items agrupados por agricultor: { farmerId: [items...] }
  Map<String, List<CartItemModel>> get itemsByFarmer {
    final map = <String, List<CartItemModel>>{};
    for (final item in _items) {
      map.putIfAbsent(item.farmerId, () => []).add(item);
    }
    return map;
  }

  bool containsProduct(String productId) =>
      _items.any((i) => i.productId == productId);

  CartItemModel? getItem(String productId) {
    try {
      return _items.firstWhere((i) => i.productId == productId);
    } catch (_) {
      return null;
    }
  }

  // ── CRUD ────────────────────────────────────────────────────────────────────

  /// Adiciona ou actualiza a quantidade se já existe.
  Future<void> addItem(CartItemModel item) async {
    final idx = _items.indexWhere((i) => i.productId == item.productId);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        quantity: _items[idx].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> updateQuantity(String productId, double quantity) async {
    final idx = _items.indexWhere((i) => i.productId == productId);
    if (idx < 0) return;
    if (quantity <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(quantity: quantity);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> removeItem(String productId) async {
    _items.removeWhere((i) => i.productId == productId);
    notifyListeners();
    await _persist();
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  Future<void> loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        _items.clear();
        _items.addAll(CartItemModel.decodeList(raw));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('CartProvider: error loading cart — $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, CartItemModel.encodeList(_items));
    } catch (e) {
      debugPrint('CartProvider: error saving cart — $e');
    }
  }
}
