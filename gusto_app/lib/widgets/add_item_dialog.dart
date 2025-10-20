import 'package:flutter/material.dart';
import 'package:gusto_app/models/recipe_model.dart';

Future<Ingredient?> showAddItemDialog(BuildContext context) async {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();

  return showDialog<Ingredient>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add Item to Shopping List'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(
                  context,
                  Ingredient(
                    name: nameController.text,
                    quantity: quantityController.text,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}
