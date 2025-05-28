import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/inven_provider.dart';
import '../model/inven_model.dart';

class ShowInvenScreen extends StatefulWidget {
   const ShowInvenScreen({super.key});

  @override
  State<ShowInvenScreen> createState() => _ShowInvenScreenState();
}

class _ShowInvenScreenState extends State<ShowInvenScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvenProvider>(context, listen: false).fetchInventoryItems();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = Provider.of<InvenProvider>(context, listen: false);
    if(_searchController.text.isEmpty) {
      provider.fetchInventoryItems();
    } else {
      provider.searchInventory(_searchController.text);
    }
  }

  Future<void> _showAddItemDialog({InvenModel? itemToEdit}) async {
    final provider = Provider.of<InvenProvider>(context, listen: false);
    final titleController = TextEditingController(text: itemToEdit?.title ?? '');
    final countController = TextEditingController(text: itemToEdit?.count.toString() ?? '');
    DateTime selectedDate = itemToEdit?.date ?? DateTime.now();

    final isEditing = itemToEdit != null;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // use a StatefulWidget for dialog content if you need to manage date picker state locally
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Item' : 'Add New Item'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(hintText: 'Item Title'),
                    ),
                    TextField(
                      controller: countController,
                      decoration: const InputDecoration(hintText: "Count"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Text("Date: ${selectedDate.toLocal().toString().split(' ')[0]}")),
                        TextButton(
                          child: const Text('Select Date'),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != selectedDate) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: Text(isEditing ? 'Save' : 'Add'),
                  onPressed: () async {
                    final title = titleController.text;
                    final count = int.tryParse(countController.text) ?? 0;

                    if (title.isEmpty) {
                      //TODO: Handle error
                      return;
                    }

                    bool success;
                    if(isEditing) {
                      final updatedItem = itemToEdit.copyWith(
                        title: title,
                        count: count,
                        date: selectedDate,
                      );
                      success = await provider.updateInventoryItem(updatedItem);
                    } else {
                      success = await provider.addInventoryItem(
                        title: title,
                        count: count,
                        date: selectedDate,
                      );
                    }

                    if(context.mounted) { // Check if widget is still in the tree
                      Navigator.of(dialogContext).pop(); // Close dialog
                      if (!success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.errorMessage ?? 'Operation failed')),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          }
        );
      }
    );
  }

  Future<void> _confirmDelete(String itemId, String itemTitle) async {
    final provider = Provider.of<InvenProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext){
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "$itemTitle"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first
                bool success = await provider.deleteInventoryItemById(itemId);
                if(!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(provider.errorMessage ?? 'Failed to delete')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to react to changes in InvenProvider
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freezer Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear All Items',
            onPressed: () async {
              final provider = Provider.of<InvenProvider>(context, listen: false);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Clear'),
                  content: const Text('Are you sure you want to delete ALL items? This cannot be undone.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await provider.clearInventoryTable();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Items',
                hintText: 'Enter item title...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },)
                    : null,
                ),
              ),
            ),
          Expanded(
            child: Consumer<InvenProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.invenItems.isEmpty) { // Show loading only if the list is empty initially
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.errorMessage != null && provider.invenItems.isEmpty){
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${provider.errorMessage}\nPull down to refresh.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (provider.invenItems.isEmpty){
                  return Center(
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? 'No items found for "${_searchController.text}".'
                          : 'The freezer is empty and the beans are hungry\nTap the "+" button to add one!',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                //TODO: Display a less intrusive loading indicator for subsequent loads/searches
                if(provider.isLoading && provider.invenItems.isNotEmpty) {
                  return const Center(child: LinearProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchInventoryItems(),
                  child: ListView.builder(
                    itemCount: provider.invenItems.length,
                    itemBuilder: (context, index) {
                      final item = provider.invenItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: Text(
                            'Count: ${item.count}\nDate: ${item.date.toLocal().toString().split(' ')[0]}'
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Decrement Button
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                                tooltip: 'Decrement Count',
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  bool success = await provider.decrementItemCount(item.id);
                                  if(!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(provider.errorMessage ?? 'Failed to decrement')),
                                    );
                                  }
                                },
                              ),
                              // Edit button
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit item',
                                onPressed: () => _showAddItemDialog(itemToEdit: item),
                              ),
                              // delete button
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Delete Item',
                                onPressed: () => _confirmDelete(item.id, item.title),
                              ),
                              // Increment Button
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                tooltip: 'Increment Count.',
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  bool success = await provider.incrementItemCount(item.id);
                                  if (!success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(provider.errorMessage ?? 'Failed to increment.')),
                                    );
                                  }
                                }
                              ),
                            ],
                          ),
                          onTap: () {
                            // TODO: Navigate to detail Screen
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)));
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }
}