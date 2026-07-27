class CalculatorState {
  final String expression;
  final String result;
  final String lastOperator; 
  final String lastOperand;  

  CalculatorState({
    this.expression = '',
    this.result = '0',
    this.lastOperator = '',
    this.lastOperand = '',
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
    String? lastOperator,
    String? lastOperand,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      lastOperator: lastOperator ?? this.lastOperator,
      lastOperand: lastOperand ?? this.lastOperand,
    );
  }
}