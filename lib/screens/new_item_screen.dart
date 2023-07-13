import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/utils/categories.dart';

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    // ignore: no_leading_underscores_for_local_identifiers
    var _enterdName = '';
    // ignore: no_leading_underscores_for_local_identifiers
    var _enterdQunatity = 1;
    // ignore: no_leading_underscores_for_local_identifiers
    var _selectedCategory = categories[Categories.vegetables]!;

    // ignore: no_leading_underscores_for_local_identifiers
    void _saveData() {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        // print(_enterdQunatity);
        // print(_selectedCategory);
        // print(_enterdName);
        Navigator.of(context).pop(GroceryItem(
            category: _selectedCategory,
            id: DateTime.now().toString(),
            name: _enterdName,
            quantity: _enterdQunatity));
      }
    }

    // ignore: no_leading_underscores_for_local_identifiers
    void _resetData() {
      formKey.currentState!.reset();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  _enterdName = newValue!;
                },
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return "Name must be between 1 and 50 characters.";
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) {
                        _enterdQunatity = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: _enterdQunatity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value)! <= 0 ||
                            int.tryParse(value) == null) {
                          return "Qunatoty must be a valid, positive number.";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.file_present,
                                  size: 25,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        _selectedCategory = value!;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(onPressed: _resetData, child: const Text('Reset')),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                      onPressed: _saveData, child: const Text('  Add  '))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
