import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/screens/new_item_screen.dart';
import 'package:shopping_list_app/utils/categories.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  List<GroceryItem> _groceryItems = [];
  var _isloading = true;
  String? _error;
  void _loadItems() async {
    final url = Uri.https(
        'shopping-app-acb15-default-rtdb.firebaseio.', 'shopping-list.json');
    try {
      final response = await http.get(url);

      if (response.body == 'null') {
        setState(() {
          _isloading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Something wnet Wrong...';
        });
      }
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isloading = false;
      });
    } catch (error) {
      setState(() {
        _isloading = false;
      });
      _error = "Something wnet Wrong...";
    }
  }

  void _addItemNavigatation() async {
    final result = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const NewItemScreen()));
    _loadItems();
    if (result == null) {
      return;
    }
    // _groceryItems.add(result);
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('shopping-app-acb15-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(
        child: Text(
      'No items added yet.',
      style: Theme.of(context)
          .textTheme
          .titleLarge!
          .copyWith(color: Theme.of(context).colorScheme.primary),
    ));
    if (_isloading) {
      content = Center(
        child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onBackground),
      );
    }
    if (_error != null) {
      content = Center(
        child: Text(_error!),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) => Dismissible(
                onDismissed: (direction) {
                  _removeItem(_groceryItems[index]);
                },
                key: ValueKey(_groceryItems[index].id),
                child: ListTile(
                  leading: Icon(
                    Icons.file_present,
                    size: 25,
                    color: _groceryItems[index].category.color,
                  ),
                  title: Text(
                    _groceryItems[index].name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  trailing: Text(
                    '${_groceryItems[index].quantity}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
              ));
    }
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('My Grocery'),
          actions: [
            IconButton(
                onPressed: _addItemNavigatation,
                icon: const Icon(Icons.add_circle_outline))
          ],
        ),
        body: content);
  }
}
