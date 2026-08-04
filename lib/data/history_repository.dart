import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'history_model.dart';

abstract class HistoryRepository {
  Future<void> add(HistoryModel entry);
  Future<void> clear();
}

class HiveHistoryRepository implements HistoryRepository {
  final Box<HistoryModel>? _customBox;

  HiveHistoryRepository([this._customBox]);

  Box<HistoryModel> get _box =>
      _customBox ?? Hive.box<HistoryModel>('calculator_history');

  @override
  Future<void> add(HistoryModel entry) async {
    try {
      final box = _box;
      await box.add(entry);
      if (box.length > 200) {
        await box.deleteAt(0);
      }
    } catch (e) {
      debugPrint('Error saving calculation history to Hive: $e');
    }
  }


  @override
  Future<void> clear() async {
    try {
      final box = _box;
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing calculation history from Hive: $e');
    }
  }
}
