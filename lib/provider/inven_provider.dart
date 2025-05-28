import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../model/inven_model.dart';
import '../db_helper/db_helper.dart';

class InvenProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  List<InvenModel> invenItems = [];

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<T> _executeDbOperation<T>(Future<T> Function() operation, {String? successMessage, String? errorMessage}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await operation();
      return result;
    } catch (e) {
      _errorMessage = errorMessage ?? "an error occured: $e";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchInventoryItems() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final dataList = await DBHelper.instance.selectAll();
      invenItems = dataList.map((item) => InvenModel.fromMap(item)).toList();
    } catch (e) {
      _errorMessage = "Failed to load inventory: $e";
      invenItems = []; // clear items on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchInventory(String searchText) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final dataList = await DBHelper.instance.search(searchText);
      invenItems = dataList.map((item) => InvenModel.fromMap(item)).toList();
    } catch (e) {
      _errorMessage = "Failed to search inventory: $e";
      // invenItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addInventoryItem({
    required String title,
    required int count,
    required DateTime date,
}) async {
    final newItem = InvenModel(
      id: _uuid.v4(),
      title: title,
      count: count,
      date: date,
    );

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final id = await DBHelper.instance.insert(newItem.toMap());
      if (id > 0) {
        await fetchInventoryItems();
        return true;
      } else {
        _errorMessage = "Failed to add item to database.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Error adding item: $e";
      notifyListeners();
      return false;
    } finally {
      if (isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updateInventoryItem(InvenModel itemToUpdate) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final rowsAffected = await DBHelper.instance.update(itemToUpdate.id, itemToUpdate.toMap());
      if (rowsAffected > 0) {
        await fetchInventoryItems();
        return true;
      } else {
        _errorMessage = "Failed to update item (item not found or no change).";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Error updating item: $e";
      notifyListeners();
      return false;
    } finally {
      if (isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // update specifics
  Future<bool> updateItemTitle(String id, String newTitle) async {
    final index = invenItems.indexWhere((item) => item.id == id);
    if (index == -1) {
      _errorMessage = "Item not found to update title.";
      notifyListeners();
      return false;
    }
    final updatedItem = invenItems[index].copyWith(title: newTitle);
    return await updateInventoryItem(updatedItem);
  }
  Future<bool> updateItemCount(String id, int newCount) async {
    final index = invenItems.indexWhere((item) => item.id == id);
    if (index == -1) {
      _errorMessage = "Item not found to update count.";
      notifyListeners();
      return false;
    }
    final updatedItem = invenItems[index].copyWith(count: newCount);
    return await updateInventoryItem(updatedItem);
  }
  Future<bool> updateItemDate(String id, DateTime newDate) async {
    final index = invenItems.indexWhere((item) => item.id == id);
    if (index == -1){
      _errorMessage = "Item not found to update date.";
      notifyListeners();
      return false;
    }
    final updatedItem = invenItems[index].copyWith(date: newDate);
    return await updateInventoryItem(updatedItem);
  }

  Future<bool> deleteInventoryItemById(String id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final rowsAffected = await DBHelper.instance.deleteById(id);
      if (rowsAffected > 0) {
        await fetchInventoryItems();
        return true;
      } else {
        _errorMessage = "Failed to delete item (item not found).";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Error deleting item: $e";
      notifyListeners();
      return false;
    } finally {
      if (isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> clearInventoryTable() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final rowsAffected = await DBHelper.instance.deleteTable();
      invenItems.clear();
      return true;
    } catch (e) {
      _errorMessage = "Error clearing inventory table: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}