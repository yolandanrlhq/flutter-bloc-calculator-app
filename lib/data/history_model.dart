import 'package:hive/hive.dart';

part 'history_model.g.dart'; 

@HiveType(typeId: 0)
class HistoryModel extends HiveObject {
  @HiveField(0)
  final String expression;

  @HiveField(1)
  final String result;

  @HiveField(2)
  final DateTime timestamp;

  HistoryModel({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}