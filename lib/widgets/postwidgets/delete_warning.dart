import 'package:flutter/material.dart';

class DeleteWarning extends StatelessWidget {
  const DeleteWarning({
    super.key,
    required this.title,
    required this.description,
    required this.okPress,
    required this.okButtonTitle,
  });
  final String title;
  final String description;
  final String okButtonTitle;
  final VoidCallback okPress;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "İptal",
          ),
        ),
        TextButton(
          onPressed: okPress,
          child: Text(
            okButtonTitle,
          ),
        ),
      ],
    );
  }
}
