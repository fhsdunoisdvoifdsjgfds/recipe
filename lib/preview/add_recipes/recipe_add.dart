import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int cookTimeHours = 0;
  int cookTimeMinutes = 0;
  int servings = 4;

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      cookTimeHours = 0;
      cookTimeMinutes = 0;
      servings = 4;
    });
  }

  void _saveRecipe() async {
    final String name = _nameController.text;
    final String description = _descriptionController.text;

    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    final recipe = {
      'name': name,
      'description': description,
      'cookTime': '$cookTimeHours:$cookTimeMinutes',
      'servings': servings,
    };

    final prefs = await SharedPreferences.getInstance();
    final String? recipesString = prefs.getString('my_recipes');
    List<Map<String, dynamic>> recipes = [];

    if (recipesString != null) {
      try {
        recipes = jsonDecode(recipesString) as List<Map<String, dynamic>>;
      } catch (e) {
        // Handle the error, e.g., log the error, show an error message to the user, or clear the corrupted data
        print('Error decoding recipes: $e');
        prefs.remove('my_recipes'); // Consider clearing the corrupted data
      }
    }

    recipes.add(recipe);
    await prefs.setString('my_recipes', jsonEncode(recipes));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved successfully!')),
    );
    print(recipes.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Recipe'),
        actions: [
          TextButton(
            onPressed: _clearForm,
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name Field
            const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(hintText: 'Name your new recipe...'),
            ),
            const SizedBox(height: 16),

            // Cook Time
            const Text('Cook Time',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Hours'),
                    onChanged: (value) {
                      setState(() {
                        cookTimeHours = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Minutes'),
                    onChanged: (value) {
                      setState(() {
                        cookTimeMinutes = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Number of Servings
            const Text('Number', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    setState(() {
                      if (servings > 1) servings--;
                    });
                  },
                ),
                Text(
                  'Serving for $servings people',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      servings++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            const Text('Description',
                style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _descriptionController,
              decoration:
                  const InputDecoration(hintText: 'Write your recipe...'),
              maxLines: 5,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveRecipe,
              child: const Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
