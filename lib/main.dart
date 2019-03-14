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
  TextSelection currentSelection =
      TextSelection(baseOffset: 0, extentOffset: 0);
  TextEditingController controller = TextEditingController(text: '1234');
  void append(String character) {
    setState(() {
      if (controller.selection.baseOffset >= 0) {
        currentSelection = TextSelection(
            baseOffset: controller.selection.baseOffset + 1,
            extentOffset: controller.selection.extentOffset + 1);
        controller.text =
            controller.text.substring(0, controller.selection.baseOffset) +
                character +
                controller.text.substring(
                    controller.selection.baseOffset, controller.text.length);
        controller.selection = currentSelection;
      } else {
        controller.text += character;
      }
    });
  }

  void clear([bool longPress = false]) {
    setState(() {
      if (longPress) {
        controller.text = '';
      } else {
        if (controller.selection.baseOffset >= 0) {
          currentSelection = TextSelection(
              baseOffset: controller.selection.baseOffset - 1,
              extentOffset: controller.selection.extentOffset - 1);
          controller.text = controller.text
                  .substring(0, controller.selection.baseOffset - 1) +
              controller.text.substring(
                  controller.selection.baseOffset, controller.text.length);
          controller.selection = currentSelection;
        } else {
          controller.text =
              controller.text.substring(0, controller.text.length - 1);
        }
      }
    });
  }

  void equals() {
    setState(() {
      Parser p = new Parser();
      try {
        controller.text = controller.text.replaceAll('e+', 'e');
        controller.text = controller.text.replaceAll('e', '*10^');
        Expression exp = p.parse(controller.text);
        num outcome = exp.evaluate(EvaluationType.REAL, ContextModel());
        controller.text = outcome
            .toStringAsPrecision(13)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      } catch (e) {
        controller.text = 'Error';
      }
    });
  }

  Widget _buildButton(Color color, String label, Function() func) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onLongPress: (label == 'C') ? () => clear(true) : null,
        child: FlatButton(
          shape: BeveledRectangleBorder(),
          child: Text(
            label,
            style: TextStyle(
                fontSize: 32.0,
                color: Colors.white,
                fontWeight: FontWeight.w300
            ),
          ),
          color: color,
          onPressed: func,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color numColor = Color.fromRGBO(48, 47, 63, .94);
    Color opColor = Color.fromRGBO(22, 21, 29, .93);
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        accentColor: Colors.greenAccent,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0.0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                decoration: null,
                textAlign: TextAlign.right,
                style: TextStyle(fontWeight: FontWeight.w300, fontSize: 80.0),
                focusNode: AlwaysDisabledFocusNode(),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(opColor, 'C', clear),
                  _buildButton(opColor, '(', () => append('(')),
                  _buildButton(opColor, ')', () => append(')')),
                  _buildButton(opColor, '\u00F7', () => append('/')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(numColor, '7', () => append('7')),
                  _buildButton(numColor, '8', () => append('8')),
                  _buildButton(numColor, '9', () => append('9')),
                  _buildButton(opColor, '\u00D7', () => append('*')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(numColor, '4', () => append('4')),
                  _buildButton(numColor, '5', () => append('5')),
                  _buildButton(numColor, '6', () => append('6')),
                  _buildButton(opColor, '-', () => append('-')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(numColor, '1', () => append('1')),
                  _buildButton(numColor, '2', () => append('2')),
                  _buildButton(numColor, '3', () => append('3')),
                  _buildButton(opColor, '+', () => append('+')),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(numColor, '%', () => append('/100')),
                  _buildButton(numColor, '0', () => append('0')),
                  _buildButton(numColor, '.', () => append('.')),
                  _buildButton(opColor, '=', equals),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}