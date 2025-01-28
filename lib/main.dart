import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Responsiva',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculadora'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _equation = '';
  String _result = '0';
  bool _isResultCalculated = false;
  final List<String> _operators = ['+', '-', '×', '÷', '%'];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _equation = '';
        _result = '0';
        _isResultCalculated = false;
        return;
      }

      if (value == '=') {
        _calculate();
        return;
      }

      if (_isResultCalculated) {
        _equation = _result;
        _result = '0';
        _isResultCalculated = false;
      }

      if (value == '.') {
        if (_equation.isEmpty || _operators.contains(_equation.substring(_equation.length - 1))) {
          _equation += '0.';
        } else {
          List<String> parts = _equation.split(RegExp(r'[+\-×÷%]'));
          if (!parts.last.contains('.')) {
            _equation += value;
          }
        }
      } else if (_operators.contains(value)) {
        if (_equation.isEmpty) {
          _equation = '0$value';
        } else {
          String lastChar = _equation.substring(_equation.length - 1);
          if (_operators.contains(lastChar)) {
            _equation = _equation.substring(0, _equation.length - 1) + value;
          } else {
            _equation += value;
          }
        }
      } else {
        _equation += value;
      }
    });
  }

  void _calculate() {
    try {
      String expression = _equation
          .replaceAll('×', '*')
          .replaceAll('÷', '/');

      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double evalResult = exp.evaluate(EvaluationType.REAL, cm);

      setState(() {
        _result = (evalResult % 1 == 0)
            ? evalResult.toInt().toString()
            : evalResult.toStringAsFixed(2);
        _isResultCalculated = true;
      });
    } catch (e) {
      setState(() {
        _result = 'Erro';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = MediaQuery.of(context).size.width * 0.2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Área de exibição
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomRight,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _equation,
                  style: TextStyle(
                    fontSize: buttonSize * 0.3,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _result,
                  style: TextStyle(
                    fontSize: buttonSize * 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Botões
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildRow(['C', '±', '%', '÷']),
                  _buildRow(['7', '8', '9', '×']),
                  _buildRow(['4', '5', '6', '-']),
                  _buildRow(['1', '2', '3', '+']),
                  _buildLastRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons
            .map((text) => CalculatorButton(
                  text: text,
                  onPressed: _onButtonPressed,
                  color: _getButtonColor(text),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildLastRow() {
    return Expanded(
      child: Row(
        children: [
          CalculatorButton(
            text: '0',
            onPressed: _onButtonPressed,
            flex: 2,
            color: Colors.grey,
          ),
          CalculatorButton(
            text: '.',
            onPressed: _onButtonPressed,
            color: Colors.grey,
          ),
          CalculatorButton(
            text: '=',
            onPressed: _onButtonPressed,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(String text) {
    if (text == 'C') return Colors.redAccent;
    if (_operators.contains(text) || text == '=') return Colors.orange;
    return Colors.grey;
  }
}

class CalculatorButton extends StatelessWidget {
  final String text;
  final Function(String) onPressed;
  final Color color;
  final int flex;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.grey,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.06,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}