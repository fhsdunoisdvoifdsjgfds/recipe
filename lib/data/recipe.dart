// models/recipe.dart
// widgets/recipe_detail_card.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recipes/data/cache.dart';
import 'package:recipes/data/data.dart';
import 'package:recipes/preview/add_recipes/recipe_favoutite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Recipe {
  final String name;
  final String image;
  final String duration;
  final String difficulty;
  final List<String> ingredients;
  final List<String> instructions;
  final String description;
  final List<String> dietary;

  Recipe(
      {required this.name,
      this.image = '',
      required this.duration,
      this.difficulty = '',
      this.ingredients = const [],
      this.instructions = const [],
      required this.description,
      this.dietary = const []});

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        name: json['name'] as String,
        image: json['image'] as String,
        duration: json['duration'] as String,
        difficulty: json['difficulty'] as String,
        ingredients: List<String>.from(json['ingredients']),
        instructions: List<String>.from(json['instructions']),
        description: json['description'] as String,
        dietary: json['dietary'] != null
            ? List<String>.from(json['dietary'])
            : const [],
      );
  factory Recipe.fromMyJson(Map<String, dynamic> json) => Recipe(
        name: json['name'] as String,
        duration: json['cookTime'] as String,
        description: json['description'] as String,
      );
}

class RecipeDetailCard extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailCard({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeDetailCard> createState() => _RecipeDetailCardState();
}

class _RecipeDetailCardState extends State<RecipeDetailCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isInFavorites =
        await FavoritesCache.isRecipeInFavorites(widget.recipe);
    setState(() {
      isFavorite = isInFavorites;
    });
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      await FavoritesCache.addToFavorites(widget.recipe);
    } else {
      await FavoritesCache.removeFromFavorites(widget.recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(
                  widget.recipe.image,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.pink),
                      onPressed: _toggleFavorite),
                ),
              ),
            ],
          ),

          // Title and Metadata
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipe.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 4),
                          Text(widget.recipe.duration),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.recipe.difficulty),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Ingredients Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.recipe.ingredients.map((ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.pink.shade300,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(ingredient),
                        ],
                      ),
                    )),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Instructions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ...widget.recipe.instructions
                    .asMap()
                    .entries
                    .map((instruction) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${instruction.key + 1}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(instruction.value),
                              ),
                            ],
                          ),
                        )),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class RecipeListScreen extends StatelessWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = RecipeData.recipes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        backgroundColor: Colors.pink,
      ),
      body: SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            return RecipeCard(recipe: recipes[index]);
          },
        ),
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        child: RecipeDetailCard(recipe: recipe),
      ),
    );
  }
}

class RecipeData {
  static final List<Recipe> recipes = [
    Recipe(
      name: 'Sweet apple pie with caramel',
      image: 'assets/images/cake/1.png',
      duration: '1h',
      difficulty: 'Simple',
      description:
          'Lorem ipsum dolor sit amet consectetur. Feugiat neque dictum ut ullamcorper mus congue tortor.',
      ingredients: [
        '2 ½ cups flour, 1 tbsp sugar, 1 tsp salt',
        '1 cup cold butter, cubed',
        '6-8 tbsp ice water',
        '6-7 Granny Smith apples, peeled and sliced',
        '½ cup sugar, ½ cup brown sugar, 1 tbsp lemon juice',
      ],
      instructions: [
        'Mix flour, sugar, and salt. Cut in butter until crumbly.',
        'Add water gradually until dough forms.',
        'Divide, wrap, and chill for 1 hour.',
        'Preheat oven to 375°F (190°C).',
      ],
    ),
    Recipe(
      name: 'Chocolate cake',
      image: 'assets/images/cake/2.png',
      duration: '45 min',
      difficulty: 'Medium',
      description: 'Rich chocolate cake with creamy frosting.',
      ingredients: [
        '2 cups flour',
        '2 cups sugar',
        '3/4 cup cocoa powder',
        '2 eggs',
        '1 cup milk',
      ],
      instructions: [
        'Mix dry ingredients.',
        'Add wet ingredients and mix well.',
        'Bake at 350°F for 30 minutes.',
        'Let cool before frosting.',
      ],
    ),
    Recipe(
      name: 'Vanilla cupcakes',
      image: 'assets/images/cake/3.png',
      duration: '30 min',
      difficulty: 'Easy',
      description: 'Light and fluffy vanilla cupcakes.',
      ingredients: [
        '1.5 cups flour',
        '1 cup sugar',
        '2 eggs',
        '1/2 cup milk',
        '1 tsp vanilla extract',
      ],
      instructions: [
        'Mix ingredients until smooth.',
        'Fill cupcake liners 2/3 full.',
        'Bake for 18-20 minutes.',
        'Cool before frosting.',
      ],
    ),
    Recipe(
      name: 'Berry cheesecake',
      image: 'assets/images/cake/4.png',
      duration: '2h',
      difficulty: 'Hard',
      description: 'Creamy cheesecake topped with fresh berries.',
      ingredients: [
        '2 cups graham cracker crumbs',
        '3 packages cream cheese',
        '1 cup sugar',
        'Fresh mixed berries',
        '3 eggs',
      ],
      instructions: [
        'Make crust and press into pan.',
        'Beat cream cheese and sugar.',
        'Add eggs one at a time.',
        'Bake in water bath for 1 hour.',
      ],
    ),
    Recipe(
      name: 'Spicy Chicken Curry',
      image: 'assets/images/cake/5.png',
      duration: '1h 15min',
      difficulty: 'Medium',
      description: 'Aromatic Indian-style chicken curry with rich spices.',
      ingredients: [
        '1 kg chicken pieces',
        '2 onions, chopped',
        '3 tbsp curry powder',
        '400ml coconut milk',
        '2 tomatoes, diced',
      ],
      instructions: [
        'Sauté onions until golden.',
        'Add spices and chicken, brown well.',
        'Pour coconut milk and simmer.',
        'Add tomatoes, cook until tender.',
      ],
    ),
    Recipe(
      name: 'Vegetarian Lasagna',
      image: 'assets/images/cake/6.png',
      duration: '1h 30min',
      difficulty: 'Hard',
      description: 'Layered vegetable lasagna with ricotta and spinach.',
      ingredients: [
        'Lasagna sheets',
        'Ricotta cheese',
        'Spinach',
        'Zucchini',
        'Marinara sauce',
      ],
      instructions: [
        'Roast vegetables.',
        'Layer pasta with cheese and veggies.',
        'Cover with sauce.',
        'Bake until golden and bubbling.',
      ],
    ),
    Recipe(
      name: 'Greek Salad',
      image: 'assets/images/cake/7.png',
      duration: '15 min',
      difficulty: 'Easy',
      description: 'Fresh Mediterranean salad with crisp vegetables.',
      ingredients: [
        'Cucumber',
        'Tomatoes',
        'Red onion',
        'Feta cheese',
        'Kalamata olives',
      ],
      instructions: [
        'Chop vegetables.',
        'Crumble feta.',
        'Mix with olive oil and oregano.',
        'Serve chilled.',
      ],
    ),
    Recipe(
      name: 'Seafood Paella',
      image: 'assets/images/cake/8.png',
      duration: '1h',
      difficulty: 'Hard',
      description: 'Traditional Spanish rice dish with mixed seafood.',
      ingredients: [
        'Arborio rice',
        'Shrimp',
        'Mussels',
        'Saffron',
        'Chorizo',
      ],
      instructions: [
        'Sauté chorizo.',
        'Add rice and saffron.',
        'Add seafood gradually.',
        'Cook until rice is crispy.',
      ],
    ),
  ];
}
