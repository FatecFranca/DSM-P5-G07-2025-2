import 'package:flutter/material.dart';
import '../../data/enums/input_size.dart';
import '../../theme/app_theme.dart';

class Input extends StatefulWidget {
  final String? label;
  final String hintText;
  final InputSize size;
  final TextEditingController controller;
  final IconData? icon;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool centerText;
  final String? suffixText;
  final FocusNode? focusNode;

  const Input({
    super.key,
    this.label,
    required this.hintText,
    required this.controller,
    this.size = InputSize.large,
    this.icon,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.centerText = false,
    this.suffixText,
    this.focusNode,
  });

  @override
  State<Input> createState() => _InputState();
}

class _InputState extends State<Input> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    // Use o focusNode externo se fornecido, caso contrário crie um interno
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isInternalFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _isInternalFocusNode = true;
    }

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    // Só dispose se for um focusNode interno
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double labelFontSize;
    double textFieldFontSize;
    double iconSize;
    double verticalPadding;

    switch (widget.size) {
      case InputSize.medium:
        labelFontSize = 14;
        textFieldFontSize = 14;
        iconSize = 20;
        verticalPadding = 14;
        break;
      case InputSize.small:
        labelFontSize = 12;
        textFieldFontSize = 12;
        iconSize = 18;
        verticalPadding = 12;
        break;
      case InputSize.large:
      default:
        labelFontSize = 16;
        textFieldFontSize = 16;
        iconSize = 22;
        verticalPadding = 10;
        break;
    }

    return Column(
      crossAxisAlignment: widget.centerText
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (widget.centerText) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null)
                Icon(widget.icon, color: AppColors.orange400, size: iconSize),
              if (widget.label != null) const SizedBox(height: 8),
              if (widget.label != null)
                Text(
                  widget.label!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: AppColors.black400,
                  ),
                ),
            ],
          ),
        ] else ...[
          Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: AppColors.orange400, size: iconSize),
                const SizedBox(width: 8),
              ],
              if (widget.label != null) ...[
                Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    color: AppColors.brown,
                  ),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              color: AppColors.orange400,
              width: _isFocused ? 2.5 : 2.0,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 90),
            child: IntrinsicWidth(
              child: Row(
                mainAxisAlignment: widget.centerText
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: widget.controller,
                      keyboardType: widget.keyboardType,
                      onChanged: widget.onChanged,
                      obscureText: widget.obscureText,
                      cursorColor: AppColors.orange400,
                      textAlign: widget.centerText
                          ? TextAlign.center
                          : TextAlign.start,
                      style: TextStyle(
                        color: AppColors.brown,
                        fontSize: textFieldFontSize,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: verticalPadding,
                        ),
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: AppColors.black200,
                          fontSize: textFieldFontSize,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (widget.suffixText != null)
                    Text(
                      widget.suffixText!,
                      style: TextStyle(
                        color: AppColors.brown,
                        fontSize: textFieldFontSize,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
