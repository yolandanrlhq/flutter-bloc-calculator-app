import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:calculator_app/logic/calculator_bloc/calculator_bloc.dart';
import 'package:calculator_app/logic/calculator_bloc/calculator_event.dart';
import 'package:calculator_app/logic/calculator_bloc/calculator_state.dart';
import 'package:calculator_app/data/history_model.dart';
import 'package:calculator_app/data/history_repository.dart';

class FailingHistoryRepository implements HistoryRepository {
  @override
  Future<void> add(HistoryModel entry) async {
    throw Exception('Hive storage failure');
  }

  @override
  Future<void> clear() async {}
}

void main() {
  late Directory tempDir;
  late CalculatorBloc bloc;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_bloc_test');
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
    bloc = CalculatorBloc();
  });

  tearDown(() async {
    await bloc.close();
  });

  group('CalculatorBloc Basic Calculations', () {
    test('5 + 3 = 8', () async {
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('+'));
      bloc.add(const NumberPressed('3'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.result == '8' && state.expression == '8')),
      );
    });

    test('20 - 5 = 15', () async {
      bloc.add(const NumberPressed('2'));
      bloc.add(const NumberPressed('0'));
      bloc.add(const OperatorPressed('-'));
      bloc.add(const NumberPressed('5'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(
            predicate<CalculatorState>((state) => state.result == '15')),
      );
    });

    test('6 × 4 = 24', () async {
      bloc.add(const NumberPressed('6'));
      bloc.add(const OperatorPressed('x'));
      bloc.add(const NumberPressed('4'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(
            predicate<CalculatorState>((state) => state.result == '24')),
      );
    });

    test('20 ÷ 5 = 4', () async {
      bloc.add(const NumberPressed('2'));
      bloc.add(const NumberPressed('0'));
      bloc.add(const OperatorPressed('÷'));
      bloc.add(const NumberPressed('5'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(
            predicate<CalculatorState>((state) => state.result == '4')),
      );
    });
  });

  group('CalculatorBloc Decimal', () {
    test('0.5 + 0.5 = 1', () async {
      bloc.add(const NumberPressed('0'));
      bloc.add(const NumberPressed('.'));
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('+'));
      bloc.add(const NumberPressed('0'));
      bloc.add(const NumberPressed('.'));
      bloc.add(const NumberPressed('5'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(
            predicate<CalculatorState>((state) => state.result == '1')),
      );
    });

    test('2.5 × 2 = 5', () async {
      bloc.add(const NumberPressed('2'));
      bloc.add(const NumberPressed('.'));
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('x'));
      bloc.add(const NumberPressed('2'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(
            predicate<CalculatorState>((state) => state.result == '5')),
      );
    });
  });

  group('CalculatorBloc Divide by zero', () {
    test('5 ÷ 0 = Cannot divide by 0', () async {
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('÷'));
      bloc.add(const NumberPressed('0'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.result == 'Cannot divide by 0')),
      );
    });
  });

  group('HIGH-001 Regression & Result Continuation', () {
    test('5 + 3 = 8, then typing 7 resets expression to 7', () async {
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('+'));
      bloc.add(const NumberPressed('3'));
      bloc.add(const CalculatePressed());
      await bloc.stream.firstWhere((s) => s.isResultShown);

      bloc.add(const NumberPressed('7'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.expression == '7' && state.result == '0')),
      );
    });

    test('5 + 3 = 8, then typing . resets expression to 0.', () async {
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('+'));
      bloc.add(const NumberPressed('3'));
      bloc.add(const CalculatePressed());
      await bloc.stream.firstWhere((s) => s.isResultShown);

      bloc.add(const NumberPressed('.'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.expression == '0.' && state.result == '0')),
      );
    });

    test('5 + 3 = 8, then + 2 = 10 (continue after result)', () async {
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('+'));
      bloc.add(const NumberPressed('3'));
      bloc.add(const CalculatePressed());
      await bloc.stream.firstWhere((s) => s.isResultShown);

      bloc.add(const OperatorPressed('+'));
      bloc.add(const NumberPressed('2'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.result == '10' && state.expression == '10')),
      );
    });
  });

  group('Unary Minus Safety', () {
    test('- followed by x does not produce broken expression', () async {
      bloc.add(const OperatorPressed('-'));
      bloc.add(const OperatorPressed('x'));
      bloc.add(const NumberPressed('5'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.expression == '-5')),
      );
    });
  });

  group('Error Recovery', () {
    test('5 ÷ 0 = Cannot divide by 0, then typing 7 recovers to normal', () async {
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('÷'));
      bloc.add(const NumberPressed('0'));
      bloc.add(const CalculatePressed());
      await bloc.stream.firstWhere((s) => s.result == 'Cannot divide by 0');

      bloc.add(const NumberPressed('7'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.expression == '7' && state.result == '0')),
      );
    });
  });

  group('Leading Zero', () {
    test('0 -> 00 -> 5 results in 5', () async {
      bloc.add(const NumberPressed('0'));
      bloc.add(const NumberPressed('00'));
      bloc.add(const NumberPressed('5'));

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.expression == '5')),
      );
    });
  });

  group('Percent Semantics', () {
    test('50% = 0.5', () async {
      bloc.add(const NumberPressed('5'));
      bloc.add(const NumberPressed('0'));
      bloc.add(const OperatorPressed('%'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.result == '0.5')),
      );
    });

    test('25% = 0.25', () async {
      bloc.add(const NumberPressed('2'));
      bloc.add(const NumberPressed('5'));
      bloc.add(const OperatorPressed('%'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.result == '0.25')),
      );
    });

    test('10% + 20% = 0.3', () async {
      bloc.add(const NumberPressed('1'));
      bloc.add(const NumberPressed('0'));
      bloc.add(const OperatorPressed('%'));
      bloc.add(const OperatorPressed('+'));
      bloc.add(const NumberPressed('2'));
      bloc.add(const NumberPressed('0'));
      bloc.add(const OperatorPressed('%'));
      bloc.add(const CalculatePressed());

      await expectLater(
        bloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.result == '0.3')),
      );
    });
  });

  group('History Repository Isolation (HIGH-003)', () {
    test('Hive storage failure does not change result to Invalid Format', () async {
      final failingBloc = CalculatorBloc(
        historyRepository: FailingHistoryRepository(),
      );

      failingBloc.add(const NumberPressed('5'));
      failingBloc.add(const OperatorPressed('+'));
      failingBloc.add(const NumberPressed('3'));
      failingBloc.add(const CalculatePressed());

      await expectLater(
        failingBloc.stream,
        emitsThrough(predicate<CalculatorState>(
            (state) => state.result == '8' && state.expression == '8')),
      );

      await failingBloc.close();
    });
  });
}
