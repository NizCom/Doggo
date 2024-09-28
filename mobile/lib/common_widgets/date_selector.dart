import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common_widgets/round_textfield.dart';

class DateSelector extends StatelessWidget {
  final TextEditingController dateController;
  final String hintText;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final void Function(DateTime)? onDateSelected; // Nullable callback

  const DateSelector({
    super.key,
    required this.dateController,
    required this.hintText,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.onDateSelected, // Optional parameter
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);

      // Call the onDateSelected callback if it's provided
      if (onDateSelected != null) {
        onDateSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: RoundTextField(
          textEditingController: dateController,
          hintText: hintText,
          icon: 'assets/icons/date_icon.png',
          textInputType: TextInputType.datetime,
          isObscureText: false,
        ),
      ),
    );
  }
}
