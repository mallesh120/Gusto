import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shopping_item.dart';
import '../../services/shopping_service.dart';
import '../../utils/app_theme.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  Category? _filter;
  bool _groupByCategory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          IconButton(
            icon: Icon(_groupByCategory ? Icons.list_rounded : Icons.category_rounded),
            tooltip: _groupByCategory ? 'Show list' : 'Group by category',
            onPressed: () => setState(() => _groupByCategory = !_groupByCategory),
          ),
          PopupMenuButton<Category?>(
            tooltip: 'Filter',
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (context) => [
              const PopupMenuItem<Category?>(value: null, child: Text('All')),
              ...Category.values.map((c) => PopupMenuItem<Category?>(
                value: c,
                child: Text(_formatCategoryName(c)),
              )),
            ],
            icon: const Icon(Icons.filter_list_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: 'More',
            onSelected: (value) {
              if (value == 'clear_bought') {
                _clearBoughtItems(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'clear_bought',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Clear bought items'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<ShoppingService>(
        builder: (context, service, _) {
          final items = _filter == null 
            ? service.items 
            : service.items.where((i) => i.category == _filter).toList();
          
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: AppTheme.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No items yet',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first item',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (_groupByCategory) {
            final grouped = <Category, List<ShoppingItem>>{};
            for (final item in items) {
              grouped.putIfAbsent(item.category, () => []).add(item);
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: grouped.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _formatCategoryName(entry.key),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.value.length} ${entry.value.length == 1 ? 'item' : 'items'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...entry.value.map((item) => _buildItemCard(context, service, item)),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildItemCard(context, service, item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Item'),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, ShoppingService service, ShoppingItem item) {
    return Dismissible(
      key: ValueKey(item.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => service.removeItem(item.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditDialog(context, service, item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: item.isChecked,
                    onChanged: (_) => service.toggleChecked(item.id),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          color: item.isChecked ? AppTheme.textSecondary : AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!_groupByCategory) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(item.category),
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatCategoryName(item.category),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  onPressed: () => _showEditDialog(context, service, item),
                  color: AppTheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCategoryName(Category category) {
    final name = category.toString().split('.').last;
    // Convert camelCase to Title Case
    return name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim().replaceFirst(
      name[0],
      name[0].toUpperCase(),
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.produce:
        return Icons.agriculture_rounded;
      case Category.meatAndSeafood:
        return Icons.set_meal_rounded;
      case Category.dairyAndEggs:
        return Icons.egg_rounded;
      case Category.pantry:
        return Icons.kitchen_rounded;
      case Category.other:
        return Icons.shopping_basket_rounded;
    }
  }

  void _clearBoughtItems(BuildContext context) async {
    final service = context.read<ShoppingService>();
    final bought = service.items.where((i) => i.isChecked).toList();
    if (bought.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No bought items to clear'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    for (final item in bought) {
      await service.removeItem(item.id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cleared ${bought.length} bought item(s)'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: AppTheme.secondary,
        ),
      );
    }
  }

  void _showAddDialog(BuildContext context) {
    final nameCtl = TextEditingController();
    Category category = Category.other;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Item'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              initialValue: category,
              items: Category.values.map((c) => DropdownMenuItem(
                value: c,
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(c), size: 20),
                    const SizedBox(width: 12),
                    Text(_formatCategoryName(c)),
                  ],
                ),
              )).toList(),
              onChanged: (v) => category = v ?? Category.other,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtl.text.trim();
              if (name.isEmpty) return;
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final userId = 'local';
              final item = ShoppingItem(
                id: id,
                name: name,
                category: category,
                userId: userId,
              );
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
        title: const Text('Edit Item'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtl,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              initialValue: category,
              items: Category.values.map((c) => DropdownMenuItem(
                value: c,
                child: Row(
                  children: [
                    Icon(_getCategoryIcon(c), size: 20),
                    const SizedBox(width: 12),
                    Text(_formatCategoryName(c)),
                  ],
                ),
              )).toList(),
              onChanged: (v) => category = v ?? Category.other,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
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
