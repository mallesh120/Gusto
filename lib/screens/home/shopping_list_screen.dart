import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_item.dart';
import '../../services/shopping_service.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  Category? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          PopupMenuButton<Category?>(
            tooltip: 'Filter',
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (context) => [
              const PopupMenuItem<Category?>(value: null, child: Text('All')),
              ...Category.values.map((c) => PopupMenuItem<Category?>(value: c, child: Text(c.toString().split('.').last))),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer<ShoppingService>(
        builder: (context, service, _) {
          final items = _filter == null ? service.items : service.items.where((i) => i.category == _filter).toList();
          if (items.isEmpty) {
            return const Center(
              child: Text('No items yet. Tap + to add'),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Dismissible(
                key: ValueKey(item.id),
                background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete, color: Colors.white)),
                secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                onDismissed: (_) => service.removeItem(item.id),
                child: ListTile(
                  leading: Checkbox(
                    value: item.isChecked,
                    onChanged: (_) => service.toggleChecked(item.id),
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.category.toString().split('.').last),
                  onTap: () => _showEditDialog(context, service, item),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtl = TextEditingController();
    Category category = Category.other;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            DropdownButtonFormField<Category>(
              initialValue: category,
              items: Category.values.map((c) => DropdownMenuItem(value: c, child: Text(c.toString().split('.').last))).toList(),
              onChanged: (v) => category = v ?? Category.other,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtl.text.trim();
              if (name.isEmpty) return;
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final userId = 'local';
              final item = ShoppingItem(id: id, name: name, category: category, userId: userId);
              context.read<ShoppingService>().addItem(item);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ShoppingService service, ShoppingItem item) {
    final nameCtl = TextEditingController(text: item.name);
    Category category = item.category;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            DropdownButtonFormField<Category>(
              initialValue: category,
              items: Category.values.map((c) => DropdownMenuItem(value: c, child: Text(c.toString().split('.').last))).toList(),
              onChanged: (v) => category = v ?? Category.other,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtl.text.trim();
              if (name.isEmpty) return;
              final updated = item.copyWith(name: name, category: category);
              service.updateItem(updated);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
