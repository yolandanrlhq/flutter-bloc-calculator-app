import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:math_expressions/math_expressions.dart';
import 'calculator_event.dart';
import 'calculator_state.dart';

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
      List<String> parts = state.expression.split(RegExp(r'[+\-x÷]'));
      String lastPart = parts.isNotEmpty ? parts.last : '';

      if (lastPart.contains('.')) {
        return; 
      }
    }
    emit(state.copyWith(expression: state.expression + event.number));
  }

  void _onOperatorPressed(OperatorPressed event, Emitter<CalculatorState> emit) {
    if (state.expression.isNotEmpty) {
      final lastChar = state.expression[state.expression.length - 1];

      if (event.operator == '%') {
        if (lastChar != '%') {
          emit(state.copyWith(expression: state.expression + '%'));
        }
        return;
      }

      if (['+', '-', 'x', '÷'].contains(lastChar)) {
        final updated = state.expression.substring(0, state.expression.length - 1) + event.operator;
        emit(state.copyWith(expression: updated));
        return;
      }
    } else if (event.operator == '-') {
      emit(state.copyWith(expression: '-'));
      return;
    }

    emit(state.copyWith(expression: state.expression + event.operator));
  }

  void _onClearPressed(ClearPressed event, Emitter<CalculatorState> emit) {
    emit(CalculatorState(expression: '', result: '0'));
  }

  void _onDeletePressed(DeletePressed event, Emitter<CalculatorState> emit) {
    if (state.expression.isNotEmpty) {
      emit(state.copyWith(
        expression: state.expression.substring(0, state.expression.length - 1),
      ));
    }
  }

  void _onCalculatePressed(CalculatePressed event, Emitter<CalculatorState> emit) {
    if (state.expression.isEmpty) return;

    try {
      String parsedExp = state.expression
          .replaceAll('x', '*')
          .replaceAll('÷', '/')
          .replaceAll('%', '/100');

      Parser p = Parser();
      Expression exp = p.parse(parsedExp);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isInfinite || eval.isNaN) {
        emit(state.copyWith(result: 'Cannot divide by 0'));
        return;
      }

      String finalResult = eval % 1 == 0 ? eval.toInt().toString() : eval.toString();

      final historyBox = Hive.box<String>('calculator_history');
      historyBox.add("${state.expression} = $finalResult");

      emit(state.copyWith(
        result: finalResult,
        expression: finalResult,
      ));
    } catch (e) {
      emit(state.copyWith(result: 'Invalid Format'));
    }
  }
}