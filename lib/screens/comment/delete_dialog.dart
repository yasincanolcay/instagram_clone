import 'package:flutter/material.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
    super.key,
    required this.title,
    required this.content,
    required this.okPress,
    required this.okButtonName,
  });
  final String title;
  final String content;
  final VoidCallback okPress;
  final String okButtonName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
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
            okButtonName,
          ),
        ),
      ],
    );
  }
}
