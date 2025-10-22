import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:PetDex/theme/app_theme.dart';
import 'package:PetDex/components/ui/custom_checkbox.dart';

class YesOrNoQuestion extends StatefulWidget {
  final String questionText;
  final String? descriptionQuestion;

  final bool? initialValue;

  final ValueChanged<bool?> onChanged;

  const YesOrNoQuestion({
    super.key,
    required this.questionText,
    this.descriptionQuestion,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<YesOrNoQuestion> createState() => _YesOrNoQuestionState();
}

class _YesOrNoQuestionState extends State<YesOrNoQuestion> {
  bool? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(YesOrNoQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state when initialValue changes (e.g., when navigating between sections)
    if (widget.initialValue != oldWidget.initialValue) {
      _selectedValue = widget.initialValue;
    }
  }

  void _handleSelection(bool isYes) {
    setState(() {
      _selectedValue = isYes;
    });

    widget.onChanged(_selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.sand,
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            children: [
              Text(
                widget.questionText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.orange900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.descriptionQuestion != null) ...[
                const SizedBox(height: 6),
                Text(
                  widget.descriptionQuestion!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppColors.orange900,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomCheckbox(
              label: "Sim",
              value: _selectedValue == true,
              onChanged: (value) {
                _handleSelection(true);
              },
            ),

            CustomCheckbox(
              label: "Não",
              value: _selectedValue == false,
              onChanged: (value) {
                _handleSelection(false);
              },
            ),
          ],
        ),
      ],
    );
  }
}
