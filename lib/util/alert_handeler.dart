// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lokal16_software/util/alerts.dart';

class AlertHandeler {
  static Future<void> newAlert(BuildContext context, AlertText text) async {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: Text(text.title),
        content: Text(text.content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(text.button),
          )
        ],
      );
    });
  }

  static Future<void> dialogWhileComputing (BuildContext context, Future<void> Function() func) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    await func();
    Navigator.of(context).pop();
  }

  static Future<String?> saveAndExit(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lämna sida'),
          content: const Text('Vill du spara dina ändringar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop("save"); // Return 'Option 1' when pressed
              },
              child: const Text("Spara och stäng"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop("exit"); // Return 'Option 2' when pressed
              },
              child: const Text("Stäng utan att spara"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Return 'Option 3' when pressed
              },
              child: const Text("Avbryt"),
            ),
          ],
        );
      }
    );
  }
}


