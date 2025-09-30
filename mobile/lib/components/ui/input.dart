import 'package:flutter/material.dart';
import '../../enums/input_size.dart';

class Input extends StatefulWidget {
  final String label;
  final String hintText;
  final InputSize size;
  final TextEditingController controller;
  final Widget? icon;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;

  const Input({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.size = InputSize.large,
    this.icon,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color orangeColor = Color(0xFFF29F05);

    double labelFontSize;

    switch (widget.size) {
      case InputSize.medium:
        labelFontSize = 14;
        break;
      case InputSize.small:
        labelFontSize = 12;
        break;
      case InputSize.large:
      default:
        labelFontSize = 16;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              color: orangeColor,
              width: _isFocused ? 2.5 : 2.0,
            ),
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            obscureText: widget.obscureText,
            cursorColor: orangeColor,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}