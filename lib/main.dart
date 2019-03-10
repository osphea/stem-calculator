import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(Calculator());
}

class Calculator extends StatefulWidget {
  @override
  CalculatorState createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  String editText = '';
  void append(String character) {
    setState(() {
      editText += character;
    });
  }

  void clear([bool longPress = false]) {
    setState(() {
      editText = longPress
          ? editText = ''
          : editText.substring(0, editText.length - 1);
    });
  }

  void equals() {
    setState(() {
      Parser p = new Parser();
      try {
        editText = editText.replaceAll('e+', 'e');
        editText = editText.replaceAll('e', '*10^');
        Expression exp = p.parse(editText);
        num outcome = exp.evaluate(EvaluationType.REAL, ContextModel());
        editText = outcome.toStringAsPrecision(13).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
      } catch (e) {
        editText = 'Error';
      }
    });
  }

  Widget _buildButton(Color color, String label, Function() func) {
    return Expanded(
      flex: 1,
      child: Container(
        padding: EdgeInsets.all(1.0),
        child: GestureDetector(
          onLongPress: (label == 'C') ? () => clear(true) : null,
          child: FlatButton(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
            ),
            color: color,
            onPressed: func,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Dahlia Calculator')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                  Text(
                    editText,
                    style: TextStyle(fontSize: 30.0),
                    maxLines: 1,
                  ),
                ])),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(Colors.grey, 'C', clear),
                  _buildButton(Colors.grey, '(', () => append('(')),
                  _buildButton(Colors.grey, ')', () => append(')')),
                  _buildButton(Colors.grey, '\u00F7', () => append('/')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(Colors.grey[400], '7', () => append('7')),
                  _buildButton(Colors.grey[400], '8', () => append('8')),
                  _buildButton(Colors.grey[400], '9', () => append('9')),
                  _buildButton(Colors.grey, '\u00D7', () => append('*')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(Colors.grey[400], '4', () => append('4')),
                  _buildButton(Colors.grey[400], '5', () => append('5')),
                  _buildButton(Colors.grey[400], '6', () => append('6')),
                  _buildButton(Colors.grey, '-', () => append('-')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(Colors.grey[400], '1', () => append('1')),
                  _buildButton(Colors.grey[400], '2', () => append('2')),
                  _buildButton(Colors.grey[400], '3', () => append('3')),
                  _buildButton(Colors.grey, '+', () => append('+')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(Colors.grey[400], '00', () => append('00')),
                  _buildButton(Colors.grey[400], '0', () => append('0')),
                  _buildButton(Colors.grey[400], '.', () => append('.')),
                  _buildButton(Colors.grey, '=', equals),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
