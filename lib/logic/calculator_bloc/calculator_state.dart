import 'package:equatable/equatable.dart';

class CalculatorState extends Equatable {
  final String expression;
  final String result;
  final String lastOperator; 
  final String lastOperand;  
  final bool isResultShown;

  const CalculatorState({
    this.expression = '',
    this.result = '0',
    this.lastOperator = '',
    this.lastOperand = '',
    this.isResultShown = false,
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
    String? lastOperator,
    String? lastOperand,
    bool? isResultShown,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      lastOperator: lastOperator ?? this.lastOperator,
      lastOperand: lastOperand ?? this.lastOperand,
      isResultShown: isResultShown ?? this.isResultShown,
    );
  }

  @override
  List<Object?> get props => [
        expression,
        result,
        lastOperator,
        lastOperand,
        isResultShown,
      ];
}