import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/shopping_item.dart';
import 'firestore_service.dart';

class ShoppingService extends ChangeNotifier {
  static const _storageKey = 'shopping_items_v1';
  
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<ShoppingItem> _items = [];
  StreamSubscription? _itemsSubscription;

  List<ShoppingItem> get items => List.unmodifiable(_items);
  bool get isAuthenticated => _auth.currentUser != null;

  ShoppingService() {
    _init();
    // Load initial data
    if (isAuthenticated) {
      _loadFromFirestoreWithMigration();
    } else {
      _loadFromLocalStorage();
    }
  }

  void _init() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadFromFirestoreWithMigration();
      } else {
        _loadFromLocalStorage();
        _itemsSubscription?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadFromLocalStorage() async {
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

  Future<void> _loadFromFirestoreWithMigration() async {
    try {
      final hasCloudData = await _firestoreService.hasCloudData();
      
      if (!hasCloudData) {
        await _migrateLocalToCloud();
      }

      _itemsSubscription?.cancel();
      _itemsSubscription = _firestoreService.shoppingItemsStream()?.listen(
        (items) {
          _items.clear();
          _items.addAll(items);
          notifyListeners();
          _saveToLocalStorage();
        },
        onError: (_) {
          _loadFromLocalStorage();
        },
      );

      _items.clear();
      _items.addAll(await _firestoreService.getShoppingItems());
      notifyListeners();
      await _saveToLocalStorage();
    } catch (e) {
      await _loadFromLocalStorage();
    }
  }

  Future<void> _migrateLocalToCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return;

      final List<dynamic> decoded = jsonDecode(raw);
      final localItems = <ShoppingItem>[];
      
      for (final e in decoded) {
        if (e is Map<String, dynamic>) {
          localItems.add(ShoppingItem.fromMap(e));
        } else if (e is Map) {
          localItems.add(ShoppingItem.fromMap(Map<String, dynamic>.from(e)));
        }
      }

      if (localItems.isNotEmpty) {
        final userId = _auth.currentUser?.uid ?? 'unknown';
        final updatedItems = localItems.map((item) {
          return item.copyWith(userId: userId);
        }).toList();

        await _firestoreService.batchAddShoppingItems(updatedItems);
        debugPrint('✅ Migrated ${updatedItems.length} shopping items to cloud');
      }
    } catch (e) {
      debugPrint('⚠️ Shopping migration error: $e');
    }
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_items.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('⚠️ Failed to cache shopping items: $e');
    }
  }

  Future<void> _persist() async {
    await _saveToLocalStorage();
  }

  Future<void> addItem(ShoppingItem item) async {
    final userId = _auth.currentUser?.uid ?? 'local';
    final itemWithUserId = item.copyWith(userId: userId);
    
    if (isAuthenticated) {
      await _firestoreService.addShoppingItem(itemWithUserId);
    } else {
      _items.add(itemWithUserId);
      await _persist();
      notifyListeners();
    }
  }

  Future<void> updateItem(ShoppingItem item) async {
    if (isAuthenticated) {
      await _firestoreService.updateShoppingItem(item);
    } else {
      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx == -1) return;
      _items[idx] = item;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> removeItem(String id) async {
    if (isAuthenticated) {
      await _firestoreService.deleteShoppingItem(id);
    } else {
      _items.removeWhere((i) => i.id == id);
      await _persist();
      notifyListeners();
    }
  }

  Future<void> toggleChecked(String id) async {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx == -1) return;
    final current = _items[idx];
    final updated = current.copyWith(isChecked: !current.isChecked);
    
    if (isAuthenticated) {
      await _firestoreService.updateShoppingItem(updated);
    } else {
      _items[idx] = updated;
      await _persist();
      notifyListeners();
    }
  }
}
