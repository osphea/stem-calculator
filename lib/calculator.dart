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
  TextSelection _currentSelection = TextSelection(baseOffset: 0, extentOffset: 0);
  TextEditingController _controller = TextEditingController(text: '');
  final GlobalKey _textFieldKey = GlobalKey();
  double _fontSize = textFieldTextStyle.fontSize;
  final _pageController = PageController(initialPage: 0);
  String _angleMode = 'DEG';
  bool _useRadians = false;

  void _changeAngleMode() {
    setState(() {
      _angleMode = (_angleMode == 'DEG') ? 'RAD' : 'DEG';
      _useRadians = !_useRadians;
    });
  }

  void _onTextChanged() {
    final inputWidth = _textFieldKey.currentContext.size.width - textFieldPadding.horizontal;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: _controller.text,
        style: textFieldTextStyle,
      ),
    );
    textPainter.layout();

    var textWidth = textPainter.width;
    var fontSize = textFieldTextStyle.fontSize;

    while (textWidth > inputWidth && fontSize > 40.0) {
      fontSize -= 0.5;
      textPainter.text = TextSpan(
        text: _controller.text,
        style: textFieldTextStyle.copyWith(fontSize: fontSize),
      );
      textPainter.layout();
      textWidth = textPainter.width;
    }

    setState(() {
      _fontSize = fontSize;
    });
  }

  void _append(String character) {
    setState(() {
      if (_controller.selection.baseOffset >= 0) {
        _currentSelection = TextSelection(
            baseOffset: _controller.selection.baseOffset + 1,
            extentOffset: _controller.selection.extentOffset + 1,
        );
        _controller.text = _controller.text.substring(0, _controller.selection.baseOffset) +
            character + _controller.text.substring(_controller.selection.baseOffset, _controller.text.length);
        _controller.selection = _currentSelection;
      } else {
        _controller.text += character;
      }
    });
    _onTextChanged();
  }

  void _clear([bool longPress = false]) {
    setState(() {
      if (longPress) {
        _controller.text = '';
      } else {
        if (_controller.selection.baseOffset >= 0) {
          _currentSelection = TextSelection(
              baseOffset: _controller.selection.baseOffset - 1,
              extentOffset: _controller.selection.extentOffset - 1);
          _controller.text = _controller.text
              .substring(0, _controller.selection.baseOffset - 1) +
              _controller.text.substring(
                  _controller.selection.baseOffset, _controller.text.length);
          _controller.selection = _currentSelection;
        } else {
          _controller.text =
              _controller.text.substring(0, _controller.text.length - 1);
        }
      }
    });
    _onTextChanged();
  }

  void _equals() {
    setState(() {
      try {
        String expText = _controller.text
            .replaceAll('e+', 'e')
            .replaceAll('e', '*10^')
            .replaceAll('÷', '/')
            .replaceAll('×', '*')
            .replaceAll('%', '/100')
            .replaceAll('log(', 'log(10,')
            .replaceAll('sin(', _useRadians ? 'sin(' : 'sin(π/180.0 *')
            .replaceAll('√(', 'sqrt(');
        Variable pi = Variable('π');
        Variable e = Variable('℮');
        Parser p = new Parser();
        Expression exp = p.parse(expText);
        ContextModel cm = ContextModel();
        cm.bindVariable(pi, Number(math.pi));
        cm.bindVariable(e, Number(math.e));
        num outcome = exp.evaluate(EvaluationType.REAL, cm);
        _controller.text = outcome
            .toStringAsPrecision(13)
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
      } catch (e) {
        _controller.text = 'Error';
      }
    });
    _onTextChanged();
  }

  Widget _buildButton(Color color, String label, Function() func) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onLongPress: (label == 'C') ? () => _clear(true) : null,
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
                controller: _controller,
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
                controller: _pageController,
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
                                  _buildButton(opColor, 'C', _clear),
                                  _buildButton(opColor, '(', () => _append('(')),
                                  _buildButton(opColor, ')', () => _append(')')),
                                  _buildButton(opColor, '÷', () => _append('÷')),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildButton(numColor, '7', () => _append('7')),
                                  _buildButton(numColor, '8', () => _append('8')),
                                  _buildButton(numColor, '9', () => _append('9')),
                                  _buildButton(opColor, '×', () => _append('×')),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildButton(numColor, '4', () => _append('4')),
                                  _buildButton(numColor, '5', () => _append('5')),
                                  _buildButton(numColor, '6', () => _append('6')),
                                  _buildButton(opColor, '-', () => _append('-')),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildButton(numColor, '1', () => _append('1')),
                                  _buildButton(numColor, '2', () => _append('2')),
                                  _buildButton(numColor, '3', () => _append('3')),
                                  _buildButton(opColor, '+', () => _append('+')),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildButton(numColor, '%', () => _append('%')),
                                  _buildButton(numColor, '0', () => _append('0')),
                                  _buildButton(numColor, '.', () => _append('.')),
                                  _buildButton(opColor, '=', _equals),
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
                          onTap: () => _pageController.animateToPage(
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
                            _buildButton(themeAccent, 'sin', () => _append('sin(')),
                            _buildButton(themeAccent, 'cos', () => _append('cos(')),
                            _buildButton(themeAccent, 'tan', () => _append('tan(')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(themeAccent, 'ln', () => _append('ln(')),
                            _buildButton(themeAccent, 'log', () => _append('log(')),
                            _buildButton(themeAccent, '√', () => _append('√(')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildButton(themeAccent, 'π', () => _append('π')),
                            _buildButton(themeAccent, 'e', () => _append('℮')),
                            _buildButton(themeAccent, '^', () => _append('^(')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //_buildButton(themeAccent, '', (){}),
                            _buildButton(themeAccent, _angleMode, _changeAngleMode),
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