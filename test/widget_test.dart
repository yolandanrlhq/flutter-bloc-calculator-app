import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:calculator_app/logic/calculator_bloc/calculator_bloc.dart';
import 'package:calculator_app/presentation/screens/calculator_screen.dart';
import 'package:calculator_app/data/history_model.dart';
import 'package:calculator_app/data/history_repository.dart';

class FakeHistoryRepository implements HistoryRepository {
  @override
  Future<void> add(HistoryModel entry) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_widget_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HistoryModelAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    if (!Hive.isBoxOpen('calculator_history')) {
      await Hive.openBox<HistoryModel>('calculator_history');
    }
  });

  testWidgets('Calculator UI: 5 + 3 = 8', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => CalculatorBloc(historyRepository: FakeHistoryRepository()),
          child: const CalculatorScreen(),
        ),
      ),
    );

    await tester.tap(find.text('5'));
    await tester.pump();

    await tester.tap(find.text('+'));
    await tester.pump();

    await tester.tap(find.text('3'));
    await tester.pump();

    await tester.tap(find.text('='));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('8'), findsNWidgets(3)); // Button 8, Expression 8, Result 8
  });
}
