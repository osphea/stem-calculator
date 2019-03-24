import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

class Calculator extends StatefulWidget {
  @override
  CalculatorState createState() => CalculatorState();
}

const textFieldPadding = EdgeInsets.only(right: 8.0);
const textFieldTextStyle = TextStyle(fontSize: 80.0, fontWeight: FontWeight.w300);
const buttonTextStyle = TextStyle(fontSize: 32.0, fontWeight: FontWeight.w300, color: Colors.white);
const themePrimary = Colors.green;
var themeAccent = Colors.green[600];
const numColor = Color.fromRGBO(48, 47, 63, .94);
const opColor = Color.fromRGBO(22, 21, 29, .93);

class CalculatorState extends State<Calculator> {
  TextSelection currentSelection = TextSelection(baseOffset: 0, extentOffset: 0);
  TextEditingController controller = TextEditingController(text: '');
  final GlobalKey _textFieldKey = GlobalKey();
  double _fontSize = textFieldTextStyle.fontSize;
  final pageController = PageController(initialPage: 0);
  String type = 'DEG';
  bool useRadians = false;

  void changeType() {
    setState(() {
      type = (type == 'DEG') ? 'RAD' : 'DEG';
      useRadians = !useRadians;
    });
  }

  void _onTextChanged() {
    final inputWidth =
        _textFieldKey.currentContext.size.width - textFieldPadding.horizontal;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: controller.text,
        style: textFieldTextStyle,
      ),
    );
    textPainter.layout();

    var textWidth = textPainter.width;
    var fontSize = textFieldTextStyle.fontSize;

    while (textWidth > inputWidth && fontSize > 40.0) {
      fontSize -= 0.5;
      textPainter.text = TextSpan(
        text: controller.text,
        style: textFieldTextStyle.copyWith(fontSize: fontSize),
      );
      textPainter.layout();
      textWidth = textPainter.width;
    }

    setState(() {
      _fontSize = fontSize;
    });
  }

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
    _onTextChanged();
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
    _onTextChanged();
  }

  void equals() {
    setState(() {
      try {
        String expText = controller.text
            .replaceAll('e+', 'e')
            .replaceAll('e', '*10^')
            .replaceAll('÷', '/')
            .replaceAll('×', '*')
            .replaceAll('%', '/100')
            .replaceAll('log(', 'log(10,')
            .replaceAll('sin(', useRadians ? 'sin(' : 'sin(π/180.0 *')
            .replaceAll('√(', 'sqrt(');
        Variable pi = Variable('π');
        Variable e = Variable('℮');
        Parser p = new Parser();
        Expression exp = p.parse(expText);
        ContextModel cm = ContextModel();
        cm.bindVariable(pi, Number(math.pi));
        cm.bindVariable(e, Number(math.e));
        num outcome = exp.evaluate(EvaluationType.REAL, cm);
        controller.text = outcome
            .toStringAsPrecision(13)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      } catch (e) {
        controller.text = 'Error';
      }
    });
    _onTextChanged();
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
            style: buttonTextStyle,
          ),
          color: color,
          onPressed: func,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: themePrimary,
        accentColor: themeAccent,
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
                key: _textFieldKey,
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: textFieldPadding,
                ),
                textAlign: TextAlign.right,
                style: textFieldTextStyle.copyWith(fontSize: _fontSize),
                focusNode: AlwaysDisabledFocusNode(),
              ),
            ),
            Expanded(
              flex: 5,
              child: PageView(
                controller: pageController,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 17,
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildButton(opColor, 'C', clear),
                                  _buildButton(opColor, '(', () => append('(')),
                                  _buildButton(opColor, ')', () => append(')')),
                                  _buildButton(opColor, '÷', () => append('÷')),
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
                                  _buildButton(opColor, '×', () => append('×')),
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
                                  _buildButton(numColor, '%', () => append('%')),
                                  _buildButton(numColor, '0', () => append('0')),
                                  _buildButton(numColor, '.', () => append('.')),
                                  _buildButton(opColor, '=', equals),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          child: Container(
                            color: themeAccent,
                            child: Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () => pageController.animateToPage(
                            1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(themeAccent, 'sin', () => append('sin(')),
                            _buildButton(themeAccent, 'cos', () => append('cos(')),
                            _buildButton(themeAccent, 'tan', () => append('tan(')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(themeAccent, 'ln', () => append('ln(')),
                            _buildButton(themeAccent, 'log', () => append('log(')),
                            _buildButton(themeAccent, '√', () => append('√(')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(themeAccent, 'π', () => append('π')),
                            _buildButton(themeAccent, 'e', () => append('℮')),
                            _buildButton(themeAccent, '^', () => append('^(')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //_buildButton(themeAccent, '', (){}),
                            _buildButton(themeAccent, type, changeType),
                            //_buildButton(themeAccent, '', (){}),
                          ],
                        ),
                      ),
                    ],
                  ),
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