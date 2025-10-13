import 'package:flutter/material.dart';
import '../../data/enums/input_size.dart';
import '../../theme/app_theme.dart';

class Input extends StatefulWidget {
  final String label;
  final String hintText;
  final InputSize size;
  final TextEditingController controller;
  final IconData? icon;
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
    double labelFontSize;
    double textFieldFontSize;
    double iconSize;
    EdgeInsets contentPadding;

    switch (widget.size) {
      case InputSize.medium:
        labelFontSize = 14;
        textFieldFontSize = 14;
        iconSize = 20;
        contentPadding =
            const EdgeInsets.symmetric(horizontal: 22, vertical: 14);
        break;
      case InputSize.small:
        labelFontSize = 12;
        textFieldFontSize = 12;
        iconSize = 18;
        contentPadding =
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        break;
      case InputSize.large:
      default:
        labelFontSize = 16;
        textFieldFontSize = 16;
        iconSize = 22;
        contentPadding =
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: AppColors.orange,
                size: iconSize,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: AppColors.black400,
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
              color: AppColors.orange,
              width: _isFocused ? 2.5 : 2.0,
            ),
          ),
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            onChanged: widget.onChanged,
            obscureText: widget.obscureText,
            cursorColor: AppColors.orange,
            style: TextStyle(
              color: AppColors.black400,
              fontSize: textFieldFontSize,
            ),
            decoration: InputDecoration(
              contentPadding: contentPadding,
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppColors.black200,
                fontSize: textFieldFontSize,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}