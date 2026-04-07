import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  final List<String> _historyList = [];
  String _operand = "";
  double _num1 = 0;
  double _num2 = 0;
  bool _shouldReset = false;
  double _memory = 0;

  double _roundResult(double value) {
    if (value.isNaN || value.isInfinite) return value;
    return double.parse(value.toStringAsFixed(10));
  }

  String _formatOutput(double value) {
    if (value.isNaN) return "Lỗi";
    if (value.isInfinite) return "Tràn số";
    
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
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
      _shouldReset = false;
    } else if (buttonText == "CE") {
      _output = "0";
    } else if (buttonText == "back") {
      if (_output.length > 1) {
        if (_output.startsWith('-') && _output.length == 2) {
          _output = "0";
        } else {
          _output = _output.substring(0, _output.length - 1);
        }
      } else {
        _output = "0";
      }
    } else if (buttonText == "+/-") {
      if (_output != "0" && _output != "Lỗi" && _output != "Tràn số") {
        if (_output.startsWith("-")) {
          _output = _output.substring(1);
        } else {
          _output = "-$_output";
        }
      }
    } else if (buttonText == "1/x") {
      double val = double.tryParse(_output.replaceAll(',', '.')) ?? 0;
      if (val != 0) {
        _output = _formatOutput(_roundResult(1 / val));
        _history = "1/(${_formatOutput(val)})";
        _shouldReset = true;
      } else {
        _output = "Lỗi";
      }
    } else if (buttonText == "x²") {
      double val = double.tryParse(_output.replaceAll(',', '.')) ?? 0;
      _output = _formatOutput(_roundResult(val * val));
      _history = "sqr(${_formatOutput(val)})";
      _shouldReset = true;
    } else if (buttonText == "√x") {
      double val = double.tryParse(_output.replaceAll(',', '.')) ?? 0;
      if (val >= 0) {
        _output = _formatOutput(_roundResult(math.sqrt(val)));
        _history = "√(${_formatOutput(val)})";
        _shouldReset = true;
      } else {
        _output = "Lỗi";
      }
    } else if (buttonText == "%") {
      double val = double.tryParse(_output.replaceAll(',', '.')) ?? 0;
      if (_operand.isNotEmpty) {
        val = val / 100 * _num1;
      } else {
        val = val / 100;
      }
      _output = _formatOutput(_roundResult(val));
      _shouldReset = true;
    } else if (buttonText == "+" ||
        buttonText == "-" ||
        buttonText == "×" ||
        buttonText == "÷") {
      if (_output == "-" || _output == "Lỗi" || _output == "Tràn số") return;
      
      _num1 = double.tryParse(_output.replaceAll(',', '.')) ?? 0;
      _operand = buttonText;
      _history = "${_formatOutput(_num1)} $buttonText";
      _shouldReset = true;
    } else if (buttonText == ",") {
      if (_shouldReset) {
        _output = "0,";
        _shouldReset = false;
      } else if (!_output.contains(',')) {
        _output = '$_output,';
      }
    } else if (buttonText == "=") {
      if (_operand.isEmpty) return; 

      _num2 = double.tryParse(_output.replaceAll(',', '.')) ?? 0;

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
        _historyList.add("$_history ${_formatOutput(_num2)} = $_output"); // Lưu lịch sử tính toán
      }

      _operand = "";
      _history = "";
      _shouldReset = true; 
    } else if (["M+", "M-", "MS", "MR", "MC"].contains(buttonText)) {
      double val = double.tryParse(_output.replaceAll(',', '.')) ?? 0;
      if (buttonText == "MS") {
        _memory = val;
        _shouldReset = true;
      } else if (buttonText == "M+") {
        _memory += val;
        _shouldReset = true;
      } else if (buttonText == "M-") {
        _memory -= val;
        _shouldReset = true;
      } else if (buttonText == "MC") {
        _memory = 0;
      } else if (buttonText == "MR") {
        _output = _formatOutput(_memory);
        _shouldReset = true;
      }
    } else {
      // Số 0-9
      if (_output == "0" || _shouldReset || _output == "Lỗi" || _output == "Tràn số") {
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
      backgroundColor: const Color(0xFF1F1F1F), // Dark Windows 11 style
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "2224802010841 - Nguyễn Văn Linh",
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: _showHistory,
                  ),
                ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _memory != 0 ? "M: ${_formatOutput(_memory)}" : "",
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            reverse: true,
                            child: Text(
                              _history,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          _output,
                          style: const TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  _buildMemoryRow(),
                  _buildRow(['%', 'CE', 'C', 'back']),
                  _buildRow(['1/x', 'x²', '√x', '÷']),
                  _buildRow(['7', '8', '9', '×']),
                  _buildRow(['4', '5', '6', '-']),
                  _buildRow(['1', '2', '3', '+']),
                  _buildRow(['+/-', '0', ',', '=']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ['MC', 'MR', 'M+', 'M-', 'MS'].map((label) {
        bool isDisabled = (label == 'MC' || label == 'MR') && _memory == 0;
        return Expanded(
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: isDisabled ? null : () => _onButtonPressed(label),
            child: Text(
              label,
              style: TextStyle(
                color: isDisabled ? Colors.grey[700] : Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRow(List<String> labels) {
    return Row(
      children: labels
          .map((label) => Expanded(child: _buildButton(label)))
          .toList(),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F1F1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Lịch Sử Tính Toán", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white54),
                    onPressed: () {
                      setState(() {
                        _historyList.clear();
                      });
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: _historyList.isEmpty
                    ? const Center(child: Text("Chưa có lịch sử tính toán", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: _historyList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              _historyList[index],
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.white, fontSize: 22),
                            ),
                          );
                        },
                      ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildButton(String label) {
    bool isOperator = ['÷', '×', '-', '+', 'back', 'C', 'CE', '%', '1/x', 'x²', '√x'].contains(label);
    bool isBlue = label == '=';

    Color bgColor = isBlue 
        ? const Color(0xFF82C8FF) 
        : (isOperator ? const Color(0xFF333333) : const Color(0xFF3F3F3F));
        
    // Phím số dùng màu tối hơn để giống form của Windows Calculator nâng cao
    if (!isOperator && !isBlue) bgColor = const Color(0xFF282828); 
    if (isOperator) bgColor = const Color(0xFF363636); 

    Color fgColor = isBlue ? Colors.black : Colors.white;

    return Container(
      margin: const EdgeInsets.all(2), // Giảm margin để khít nhau đẹp hơn
      height: 65, // Để vừa 6 hàng trên mobile thông thường
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shadowColor: Colors.transparent, // Bỏ bóng để làm phẳng giống Win11
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Bo tròn nhẹ
          ),
          elevation: 0,
        ),
        onPressed: () => _onButtonPressed(label),
        child: label == 'back'
            ? const Icon(Icons.backspace_outlined, size: 24)
            : Text(label, style: TextStyle(
                fontSize: (label == '1/x' || label == 'x²' || label == '√x') ? 20 : 28,
                fontWeight: isBlue ? FontWeight.w500 : FontWeight.w400,
              )),
      ),
    );
  }
}