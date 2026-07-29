import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:math_expressions/math_expressions.dart';
import 'calculator_event.dart';
import 'calculator_state.dart';
import '../../data/history_model.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  CalculatorBloc() : super(CalculatorState()) {
    on<NumberPressed>(_onNumberPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<ClearPressed>(_onClearPressed);
    on<DeletePressed>(_onDeletePressed);
    on<CalculatePressed>(_onCalculatePressed);
  }

  void _onNumberPressed(NumberPressed event, Emitter<CalculatorState> emit) {
    if (event.number == '.') {
      if (state.expression.isEmpty || state.expression == '0') {
        emit(state.copyWith(expression: '0.'));
        return;
      }

      List<String> parts = state.expression.split(RegExp(r'[+\-x÷]'));
      String lastPart = parts.isNotEmpty ? parts.last : '';

      if (lastPart.isEmpty) {
        emit(state.copyWith(expression: '${state.expression}0.'));
        return;
      }

      if (lastPart.contains('.')) {
        return;
      }
    }

    if (state.expression == '0' && event.number != '.') {
      emit(state.copyWith(expression: event.number)); 
      return;
    }

    emit(state.copyWith(expression: state.expression + event.number));
  }

  void _onOperatorPressed(
      OperatorPressed event,
      Emitter<CalculatorState> emit,
  ) {
    if (state.expression.isEmpty) {
      if (event.operator == '-') {
        emit(state.copyWith(expression: '-'));
      }
      return;
    }

    final lastChar = state.expression[state.expression.length - 1];

    if (event.operator == '%') {
      if (['+', '-', 'x', '÷', '%'].contains(lastChar)) {
        return;
      }

      emit(state.copyWith(
        expression: '${state.expression}%',
      ));
      return;
    }

    if (['+', '-', 'x', '÷'].contains(lastChar)) {
      emit(state.copyWith(
        expression: state.expression.substring(
              0,
              state.expression.length - 1,
            ) +
            event.operator,
      ));
      return;
    }

    emit(state.copyWith(
      expression: state.expression + event.operator,
    ));
  }

  void _onClearPressed(ClearPressed event, Emitter<CalculatorState> emit) {
    emit(CalculatorState(
      expression: '',
      result: '0',
      lastOperator: '',
      lastOperand: '',
    ));
  }

  void _onDeletePressed(DeletePressed event, Emitter<CalculatorState> emit) {
    if (state.expression.isNotEmpty) {
      emit(state.copyWith(
        expression: state.expression.substring(0, state.expression.length - 1),
      ));
    }
  }

  String convertPercentExpression(String exp) {
    exp = exp.replaceAllMapped(
      RegExp(r'(\d+(\.\d+)?)\*(\d+(\.\d+)?)%'),
      (m) {
        double a = double.parse(m.group(1)!);
        double b = double.parse(m.group(3)!);
        return (a * b / 100).toString();
      },
    );

    exp = exp.replaceAllMapped(
      RegExp(r'(\d+(\.\d+)?)/(\d+(\.\d+)?)%'),
      (m) {
        double a = double.parse(m.group(1)!);
        double b = double.parse(m.group(3)!);
        return (a / (b / 100)).toString();
      },
    );

    exp = exp.replaceAllMapped(
      RegExp(r'(\d+(\.\d+)?)\+(\d+(\.\d+)?)%'),
      (m) {
        double a = double.parse(m.group(1)!);
        double b = double.parse(m.group(3)!);
        return (a + (a * b / 100)).toString();
      },
    );

    exp = exp.replaceAllMapped(
      RegExp(r'(\d+(\.\d+)?)-(\d+(\.\d+)?)%'),
      (m) {
        double a = double.parse(m.group(1)!);
        double b = double.parse(m.group(3)!);
        return (a - (a * b / 100)).toString();
      },
    );

    exp = exp.replaceAllMapped(
      RegExp(r'(\d+(\.\d+)?)%'),
      (m) {
        return (double.parse(m.group(1)!) / 100).toString();
      },
    );

    return exp;
  }

  void _onCalculatePressed(CalculatePressed event, Emitter<CalculatorState> emit) async {
    if (state.expression.isEmpty) return;

    String currentExpression = state.expression;
    currentExpression = currentExpression.trim();
    String newLastOperator = state.lastOperator;
    String newLastOperand = state.lastOperand;

    bool isOnlyNumber =
        RegExp(r'^-?\d+(\.\d+)?%?$').hasMatch(currentExpression);

    if (isOnlyNumber && state.lastOperator.isNotEmpty && state.lastOperand.isNotEmpty) {
      currentExpression = "$currentExpression${state.lastOperator}${state.lastOperand}";
    } else {
      RegExp regExp = RegExp(r'([+\-x÷])([0-9.]+%?)$');
      Match? match = regExp.firstMatch(currentExpression);
      if (match != null) {
        newLastOperator = match.group(1) ?? '';
        newLastOperand = match.group(2) ?? '';
      }
    }

    final lastChar = currentExpression[currentExpression.length - 1];

    if (['+', '-', 'x', '÷'].contains(lastChar)) {
      emit(state.copyWith(result: 'Invalid Format'));
      return;
    }

    if (currentExpression.contains('%%')) {
      emit(state.copyWith(result: 'Invalid Format'));
      return;
    }

    try {
      String parsedExp = currentExpression
          .replaceAll('x', '*')
          .replaceAll('÷', '/');

      parsedExp = convertPercentExpression(parsedExp);

      Parser p = Parser();
      Expression exp = p.parse(parsedExp);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isInfinite || eval.isNaN) {
        emit(state.copyWith(result: 'Cannot divide by 0'));
        return;
      }

      String finalResult = formatResult(eval);

      final historyBox = Hive.box<HistoryModel>('calculator_history');
      final newHistory = HistoryModel(
        expression: currentExpression,
        result: finalResult,
        timestamp: DateTime.now(),
      );

      await historyBox.add(newHistory);
      await historyBox.flush();

      emit(state.copyWith(
        result: finalResult,
        expression: finalResult, 
        lastOperator: newLastOperator,
        lastOperand: newLastOperand,
      ));
    } catch (e) {
      emit(state.copyWith(result: 'Invalid Format'));
    }
  }

  String formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(6)
        .replaceFirst(RegExp(r'\.?0+$'), '');
  }
}