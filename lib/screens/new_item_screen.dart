import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/utils/categories.dart';
import 'package:http/http.dart' as http;

class NewItemScreen extends StatefulWidget {
  const NewItemScreen({super.key});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  var _isSaving = false;

  final formKey = GlobalKey<FormState>();
  // ignore: no_leading_underscores_for_local_identifiers
  var _enterdName = '';
  // ignore: no_leading_underscores_for_local_identifiers
  var _enterdQunatity = 1;
  // ignore: no_leading_underscores_for_local_identifiers
  var _selectedCategory = categories[Categories.vegetables]!;
  // ignore: no_leading_underscores_for_local_identifiers
  void _saveData() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      setState(() {
        _isSaving = true;
      });
      final url = Uri.https('shopping-app-acb15-default-rtdb.firebaseio.com',
          'shopping-list.json');
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _enterdName,
            'quantity': _enterdQunatity,
            'category': _selectedCategory.title,
          }));

      // ignore: use_build_context_synchronously
      if (!context.mounted) {
        return;
      }
      final Map<String, dynamic> resData = json.decode(response.body);
      Navigator.of(context).pop(GroceryItem(
        id: resData['name'],
        name: _enterdName,
        quantity: _enterdQunatity,
        category: _selectedCategory,
      ));
    }
  }

  // ignore: no_leading_underscores_for_local_identifiers
  void _resetData() {
    formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
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
                      value: _selectedCategory,
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
                  TextButton(
                      onPressed: _isSaving == true ? null : _resetData,
                      child: const Text('Reset')),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                      onPressed: _isSaving == true ? null : _saveData,
                      child: _isSaving == true
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add new Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
