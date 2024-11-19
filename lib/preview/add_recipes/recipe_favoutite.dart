import 'dart:convert';
import 'package:recipes/data/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:recipes/data/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const String favoritesKey = 'favorites_list';

  // Добавление в избранное
  static Future<void> addToFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Очищаем текущий список
      await prefs.remove(favoritesKey);

      // Получаем текущие избранные
      List<Recipe> favorites = await getFavorites();

      // Проверяем есть ли уже такой рецепт
      if (!favorites.any((r) => r.name == recipe.name)) {
        favorites.add(recipe);
      }

      // Конвертируем и сохраняем новый список
      final encoded =
          favorites.map((r) => jsonEncode(_recipeToMap(r))).toList();
      await prefs.setStringList(favoritesKey, encoded);

      // Для отладки
      print('Saved favorites: ${encoded.length} items');
      print(encoded);
    } catch (e) {
      print('Error adding to favorites: $e');
    }
  }

  // Удаление из избранного
  static Future<void> removeFromFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Очищаем текущий список
      await prefs.remove(favoritesKey);

      // Получаем текущие избранные
      List<Recipe> favorites = await getFavorites();

      // Удаляем рецепт
      favorites.removeWhere((r) => r.name == recipe.name);

      // Конвертируем и сохраняем обновленный список
      final encoded =
          favorites.map((r) => jsonEncode(_recipeToMap(r))).toList();
      await prefs.setStringList(favoritesKey, encoded);

      // Для отладки
      print('Updated favorites: ${encoded.length} items');
      print(encoded);
    } catch (e) {
      print('Error removing from favorites: $e');
    }
  }

  // Получение списка избранного
  static Future<List<Recipe>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesData = prefs.getStringList('favorite_recipes') ?? [];

      // Для отладки
      print('Loading favorites: ${favoritesData.length} items');

      return favoritesData
          .map((data) => _mapToRecipe(jsonDecode(data)))
          .toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  // Проверка наличия в избранном
  static Future<bool> isInFavorites(Recipe recipe) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((r) => r.name == recipe.name);
    } catch (e) {
      print('Error checking favorites: $e');
      return false;
    }
  }

  // Очистка всех избранных
  static Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(favoritesKey);
      print('Favorites cleared');
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  // Конвертация Recipe в Map
  static Map<String, dynamic> _recipeToMap(Recipe recipe) {
    return {
      'name': recipe.name,
      'image': recipe.image,
      'duration': recipe.duration,
      'difficulty': recipe.difficulty,
      'ingredients': recipe.ingredients,
      'instructions': recipe.instructions,
      'description': recipe.description,
      'dietary': recipe.dietary,
    };
  }

  // Конвертация Map в Recipe
  static Recipe _mapToRecipe(Map<String, dynamic> map) {
    return Recipe(
      name: map['name'],
      image: map['image'],
      duration: map['duration'],
      difficulty: map['difficulty'],
      ingredients: List<String>.from(map['ingredients']),
      instructions: List<String>.from(map['instructions']),
      description: map['description'],
      dietary: List<String>.from(map['dietary'] ?? []),
    );
  }
}
