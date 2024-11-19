import 'package:flutter/material.dart';
import 'package:recipes/data/data.dart';
import 'package:recipes/data/recipe.dart';
import 'package:recipes/preview/add_recipes/recipe_favoutite.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Recipe> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    final favs = await FavoritesManager.getFavorites();
    setState(() {
      favorites = favs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : favorites.isEmpty
              ? const Center(
                  child: Text(
                    'No favorites yet!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(favorites[index].name),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) async {
                          final recipe = favorites[index];
                          setState(() {
                            favorites.removeAt(index);
                          });
                          await FavoritesManager.removeFromFavorites(recipe);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('${recipe.name} removed from favorites'),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: RecipeCard(recipe: favorites[index]),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
