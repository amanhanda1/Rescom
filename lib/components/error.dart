import 'package:flutter/material.dart';

class CustomErrorDialog extends StatelessWidget {
  final String message;

  const CustomErrorDialog({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error',style:TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('OK',style:TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
