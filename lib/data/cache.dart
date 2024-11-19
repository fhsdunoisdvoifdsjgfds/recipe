import 'dart:convert';

import 'package:recipes/data/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesCache {
  static const String _favoritesKey = 'favorite_recipes';

  // Check if a recipe is in favorites
  static Future<bool> isRecipeInFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      // Convert each stored recipe JSON string back to a map for comparison
      final favoriteRecipes = favoritesJson
          .map((json) => jsonDecode(json) as Map<String, dynamic>)
          .toList();

      // Check if recipe exists by comparing names
      // You might want to use a more unique identifier if available
      return favoriteRecipes
          .any((favRecipe) => favRecipe['name'] == recipe.name);
    } catch (e) {
      print('Error checking favorites: $e');
      return false;
    }
  }

  static Future<void> addToFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      final recipeJson = jsonEncode({
        'name': recipe.name,
        'image': recipe.image,
        'duration': recipe.duration,
        'difficulty': recipe.difficulty,
        'ingredients': recipe.ingredients,
        'instructions': recipe.instructions,
        'description': recipe.description,
        'dietary': recipe.dietary,
      });
      if (!favoritesJson.contains(recipeJson)) {
        favoritesJson.add(recipeJson);
        await prefs.setStringList(_favoritesKey, favoritesJson);
        print('added');
      }
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  static Future<void> removeFromFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      // Remove recipe by name
      favoritesJson.removeWhere((json) {
        final favRecipe = jsonDecode(json) as Map<String, dynamic>;
        return favRecipe['name'] == recipe.name;
      });

      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }
}

class FavoritesManager {
  static const String _favoritesKey = 'favorite_recipes';

  // Get all favorites from cache
  static Future<List<Recipe>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.map((json) {
        final Map<String, dynamic> recipeMap = jsonDecode(json);
        return Recipe(
          name: recipeMap['name'],
          image: recipeMap['image'],
          duration: recipeMap['duration'],
          difficulty: recipeMap['difficulty'],
          ingredients: List<String>.from(recipeMap['ingredients']),
          instructions: List<String>.from(recipeMap['instructions']),
          description: recipeMap['description'],
          dietary: List<String>.from(recipeMap['dietary'] ?? []),
        );
      }).toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  // Check if recipe is in favorites
  static Future<bool> isRecipeInFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.any((json) {
        final favRecipe = jsonDecode(json) as Map<String, dynamic>;
        return favRecipe['name'] == recipe.name;
      });
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Add recipe to favorites
  static Future<void> addToFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      final recipeJson = jsonEncode({
        'name': recipe.name,
        'image': recipe.image,
        'duration': recipe.duration,
        'difficulty': recipe.difficulty,
        'ingredients': recipe.ingredients,
        'instructions': recipe.instructions,
        'description': recipe.description,
        'dietary': recipe.dietary,
      });

      if (!favoritesJson.contains(recipeJson)) {
        favoritesJson.add(recipeJson);
        await prefs.setStringList(_favoritesKey, favoritesJson);
      }
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Remove recipe from favorites
  static Future<void> removeFromFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      favoritesJson.removeWhere((json) {
        final favRecipe = jsonDecode(json) as Map<String, dynamic>;
        return favRecipe['name'] == recipe.name;
      });

      await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }
}
