import 'package:flutter/material.dart';

Future<void> showLimitReachedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('You\'ve reached a limit!'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('You\'ve reached the maximum number of recipes for the free tier.'),
              SizedBox(height: 10),
              Text('Upgrade to Gusto Pro for unlimited saves and more!'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Learn More'),
            onPressed: () {
              // TODO: Implement navigation to a "Gusto Pro" marketing page
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
