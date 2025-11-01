import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

class ShoppingService extends ChangeNotifier {
  static const _storageKey = 'shopping_items_v1';

  final List<ShoppingItem> _items = [];

  List<ShoppingItem> get items => List.unmodifiable(_items);

  ShoppingService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      _items.clear();
      for (final e in decoded) {
        if (e is Map<String, dynamic>) {
          _items.add(ShoppingItem.fromMap(e));
        } else if (e is Map) {
          _items.add(ShoppingItem.fromMap(Map<String, dynamic>.from(e)));
        }
      }
      notifyListeners();
    } catch (_) {
      // ignore parse errors and start fresh
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_items.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> addItem(ShoppingItem item) async {
    _items.add(item);
    await _persist();
    notifyListeners();
  }

  Future<void> updateItem(ShoppingItem item) async {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx == -1) return;
    _items[idx] = item;
    await _persist();
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> toggleChecked(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final current = _items[idx];
    _items[idx] = current.copyWith(isChecked: !current.isChecked);
    await _persist();
    notifyListeners();
  }
}
