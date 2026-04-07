import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _history = "";
  String _operand = "";
  double _num1 = 0;
  double _num2 = 0;
  bool _shouldReset = false;

  // Làm tròn để tránh lỗi floating point
  double _roundResult(double value) {
    return double.parse(value.toStringAsFixed(10));
  }

  String _formatOutput(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    // Bỏ số 0 thừa ở cuối (vd: 7,50 → 7,5)
    String str = value.toString();
    str = str.replaceAll('.', ',');
    return str;
  }

  void _onButtonPressed(String buttonText) {
    if (buttonText == "C") {
      _output = "0";
      _history = "";
      _num1 = 0;
      _num2 = 0;
      _operand = "";
    } else if (buttonText == "back") {
      if (_output.length > 1) {
        _output = _output.substring(0, _output.length - 1);
      } else {
        _output = "0";
      }
    } else if (buttonText == "-" && (_output == "0" || (_shouldReset && _operand.isNotEmpty))) {
      _output = "-";
      _shouldReset = false;
    } else if (buttonText == "+" ||
        buttonText == "-" ||
        buttonText == "×" ||
        buttonText == "÷") {
      if (_output == "-") return; // Ngăn lỗi parse nếu chỉ có mỗi dấu trừ
      
      _num1 = double.parse(_output.replaceAll(',', '.'));
      _operand = buttonText;
      _history = "$_output $buttonText";
      _shouldReset = true;
    } else if (buttonText == ",") {
      if (!_output.contains(',')) {
        _output = '$_output,';
      }
    } else if (buttonText == "=") {
      if (_operand.isEmpty) return; // ✅ Guard: chưa chọn toán tử thì bỏ qua

      _num2 = double.parse(_output.replaceAll(',', '.'));

      double result = 0;
      bool hasError = false;

      if (_operand == "+") result = _roundResult(_num1 + _num2);
      if (_operand == "-") result = _roundResult(_num1 - _num2);
      if (_operand == "×") result = _roundResult(_num1 * _num2);
      if (_operand == "÷") {
        if (_num2 == 0) {
          _output = "Lỗi";
          hasError = true;
        } else {
          result = _roundResult(_num1 / _num2);
        }
      }

      if (!hasError) {
        _output = _formatOutput(result);
      }

      _operand = "";
      _history = "";
      _shouldReset = true; // ✅ Sau khi = , nhập số mới sẽ reset
    } else {
      if (_output == "0" || _shouldReset) {
        _output = buttonText;
        _shouldReset = false;
      } else {
        _output = _output + buttonText;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                "2224802010841 - Nguyễn Văn Linh",
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Wrap history bằng Expanded để tránh overflow
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Text(
                          _history,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _output,
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildRow(['0', 'C', ',', 'back']),
                  _buildRow(['7', '8', '9', '÷']),
                  _buildRow(['4', '5', '6', '×']),
                  _buildRow(['1', '2', '3', '-']),
                  _buildLastRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels) {
    return Row(
      children: labels
          .map((label) => Expanded(child: _buildButton(label)))
          .toList(),
    );
  }

  Widget _buildLastRow() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildButton('=', isBlue: true)),
        Expanded(flex: 1, child: _buildButton('+')),
      ],
    );
  }

  Widget _buildButton(String label, {bool isBlue = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isBlue ? const Color(0xFF82C8FF) : const Color(0xFF2D2D2D),
          foregroundColor: isBlue ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: () => _onButtonPressed(label),
        child: label == 'back'
            ? const Icon(Icons.backspace_outlined)
            : Text(label, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}