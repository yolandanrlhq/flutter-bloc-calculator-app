import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_expressions/math_expressions.dart';
import 'calculator_event.dart';
import 'calculator_state.dart';
import '../../data/history_model.dart';
import '../../data/history_repository.dart';

class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final HistoryRepository _historyRepository;

  CalculatorBloc({HistoryRepository? historyRepository})
      : _historyRepository = historyRepository ?? HiveHistoryRepository(),
        super(const CalculatorState()) {
    on<NumberPressed>(_onNumberPressed);
    on<OperatorPressed>(_onOperatorPressed);
    on<ClearPressed>(_onClearPressed);
    on<DeletePressed>(_onDeletePressed);
    on<CalculatePressed>(_onCalculatePressed);
  }

  void _onNumberPressed(NumberPressed event, Emitter<CalculatorState> emit) {
    if (state.isResultShown ||
        state.result == 'Invalid Format' ||
        state.result == 'Cannot divide by 0') {
      if (event.number == '.') {
        emit(state.copyWith(
          expression: '0.',
          isResultShown: false,
          result: '0',
        ));
      } else if (event.number == '00') {
        emit(state.copyWith(
          expression: '0',
          isResultShown: false,
          result: '0',
        ));
      } else {
        emit(state.copyWith(
          expression: event.number,
          isResultShown: false,
          result: '0',
        ));
      }
      return;
    }

    if (event.number == '.') {
      if (state.expression.isEmpty || state.expression == '0') {
        emit(state.copyWith(expression: '0.'));
        return;
      }

      List<String> parts = state.expression.split(RegExp(r'[+\-x÷%]'));
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
      if (event.number == '00') {
        emit(state.copyWith(expression: '0'));
      } else {
        emit(state.copyWith(expression: event.number));
      }
      return;
    }

    emit(state.copyWith(expression: state.expression + event.number));
  }

  void _onOperatorPressed(
    OperatorPressed event,
    Emitter<CalculatorState> emit,
  ) {
    String currentResult = state.result;
    if (currentResult == 'Invalid Format' ||
        currentResult == 'Cannot divide by 0') {
      currentResult = '0';
    }

    if (state.expression.isEmpty) {
      if (event.operator == '-') {
        emit(state.copyWith(
          expression: '-',
          isResultShown: false,
          result: currentResult,
        ));
      }
      return;
    }

    if (state.expression == '-' && event.operator != '-') {
      return;
    }

    final lastChar = state.expression[state.expression.length - 1];

    if (event.operator == '%') {
      if (['+', '-', 'x', '÷', '%'].contains(lastChar)) {
        return;
      }

      emit(state.copyWith(
        expression: '${state.expression}%',
        isResultShown: false,
        result: currentResult,
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
        isResultShown: false,
        result: currentResult,
      ));
      return;
    }

    emit(state.copyWith(
      expression: state.expression + event.operator,
      isResultShown: false,
      result: currentResult,
    ));
  }

  void _onClearPressed(ClearPressed event, Emitter<CalculatorState> emit) {
    emit(const CalculatorState(
      expression: '',
      result: '0',
      lastOperator: '',
      lastOperand: '',
      isResultShown: false,
    ));
  }

  void _onDeletePressed(DeletePressed event, Emitter<CalculatorState> emit) {
    if (state.expression.isNotEmpty) {
      emit(state.copyWith(
        expression: state.expression.substring(0, state.expression.length - 1),
        isResultShown: false,
      ));
    }
  }

  String convertPercentExpression(String exp) {
    return exp.replaceAllMapped(
      RegExp(r'(\d+(\.\d+)?)%'),
      (m) => '(${m.group(1)}/100)',
    );
  }

  void _onCalculatePressed(
      CalculatePressed event, Emitter<CalculatorState> emit) async {
    if (state.expression.isEmpty) return;

    String currentExpression = state.expression;
    currentExpression = currentExpression.trim();
    String newLastOperator = state.lastOperator;
    String newLastOperand = state.lastOperand;

    bool isOnlyNumber =
        RegExp(r'^-?\d+(\.\d+)?%?$').hasMatch(currentExpression);

    if (isOnlyNumber &&
        state.lastOperator.isNotEmpty &&
        state.lastOperand.isNotEmpty) {
      currentExpression =
          "$currentExpression${state.lastOperator}${state.lastOperand}";
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

    double eval;
    String finalResult;
    try {
      String parsedExp =
          currentExpression.replaceAll('x', '*').replaceAll('÷', '/');

      parsedExp = convertPercentExpression(parsedExp);

      ShuntingYardParser p = ShuntingYardParser();
      Expression exp = p.parse(parsedExp);
      ContextModel cm = ContextModel();
      eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isInfinite || eval.isNaN) {
        emit(state.copyWith(result: 'Cannot divide by 0'));
        return;
      }

      finalResult = formatResult(eval);
    } catch (e) {
      emit(state.copyWith(result: 'Invalid Format'));
      return;
    }

    try {
      final newHistory = HistoryModel(
        expression: currentExpression,
        result: finalResult,
        timestamp: DateTime.now(),
      );
      await _historyRepository.add(newHistory);
    } catch (e) {
      // Storage error is logged and ignored so calculation result stays valid
    }

    emit(state.copyWith(
      result: finalResult,
      expression: finalResult,
      lastOperator: newLastOperator,
      lastOperand: newLastOperand,
      isResultShown: true,
    ));

  }

  String formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}