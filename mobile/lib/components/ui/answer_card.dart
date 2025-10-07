import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnswerCard extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final EdgeInsets padding;

  const AnswerCard({
    super.key,
    this.hintText = 'Insira sua resposta',
    this.controller,
    this.onChanged,
    this.maxLines = 3,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.sand300,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: padding,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.black200,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: const TextStyle(
          color: AppColors.black400,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class AnswerCard2 extends StatefulWidget {
  final String hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final int maxLines;
  final int? maxLength;
  final EdgeInsets padding;
  final bool enabled;

  const AnswerCard2({
    super.key,
    this.hintText = 'Insira sua resposta',
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 4,
    this.maxLength,
    this.padding = const EdgeInsets.all(16),
    this.enabled = true,
  });

  @override
  State<AnswerCard2> createState() => _AnswerCard2State();
}

class _AnswerCard2State extends State<AnswerCard2> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();

    _controller.addListener(() {
      if (widget.onChanged != null) {
        widget.onChanged!(_controller.text);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get value => _controller.text;

  void clear() {
    _controller.clear();
  }

  void setValue(String value) {
    _controller.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 80,
        maxHeight: 200,
      ),
      decoration: BoxDecoration(
        color: AppColors.sand300,
        borderRadius: BorderRadius.circular(12),
        border: _focusNode.hasFocus
          ? Border.all(color: AppColors.orange400, width: 1.5)
          : null,
      ),
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) {
          if (widget.onSubmitted != null) {
            widget.onSubmitted!();
          }
        },
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.black200,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          counterText: '',
          isDense: true,
        ),
        style: TextStyle(
          color: widget.enabled ? AppColors.black400 : AppColors.black200,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        textAlignVertical: TextAlignVertical.top,
        scrollPhysics: const BouncingScrollPhysics(),
      ),
    );
  }
}