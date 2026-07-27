class CalculatorState {
  final String expression;
  final String result;

  CalculatorState({
    this.expression = '',
    this.result = '0',
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
    );
  }
}