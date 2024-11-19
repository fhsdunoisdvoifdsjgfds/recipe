// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:recipes/data/data.dart';
import 'package:recipes/data/recipe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  List<Recipe> filteredRecipes = [];
  FilterSettings filterSettings = FilterSettings();

  @override
  void initState() {
    super.initState();
    filteredRecipes = RecipeData.recipes;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      isSearching = query.isNotEmpty;
      filteredRecipes = RecipeData.recipes.where((recipe) {
        return recipe.name.toLowerCase().contains(query) &&
            _matchesFilter(recipe);
      }).toList();
    });
  }

  bool _matchesFilter(Recipe recipe) {
    if (filterSettings.cookTime != null &&
        int.parse(recipe.duration.replaceAll(RegExp(r'[^0-9]'), '')) >
            filterSettings.cookTime!) {
      return false;
    }

    if (filterSettings.difficulty != null &&
        recipe.difficulty != filterSettings.difficulty) {
      return false;
    }

    if (filterSettings.dietary.isNotEmpty &&
        !filterSettings.dietary
            .every((diet) => recipe.dietary.contains(diet))) {
      return false;
    }

    return true;
  }

  void _applyFilters(FilterSettings settings) {
    setState(() {
      filterSettings = settings;
      _onSearchChanged();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => FilterDrawer(
                          currentSettings: filterSettings,
                          onApplyFilters: _applyFilters,
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: isSearching
                  ? ListView.builder(
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        return RecipeListItem(recipe: filteredRecipes[index]);
                      },
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Popular Recipes',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredRecipes.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailScreen(
                                                recipe: filteredRecipes[index]),
                                      ),
                                    );
                                  },
                                  child: RecipeCard(
                                      recipe: filteredRecipes[index]),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'All Recipes',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredRecipes.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailScreen(
                                          recipe: filteredRecipes[index]),
                                    ),
                                  );
                                },
                                child: RecipeListItem(
                                    recipe: filteredRecipes[index]),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterSettings {
  int? cookTime;
  String? difficulty;
  Set<String> dietary;

  FilterSettings({
    this.cookTime,
    this.difficulty,
    this.dietary = const {},
  });

  FilterSettings copyWith({
    int? cookTime,
    String? difficulty,
    Set<String>? dietary,
  }) {
    return FilterSettings(
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      dietary: dietary ?? this.dietary,
    );
  }
}

class FilterDrawer extends StatefulWidget {
  final FilterSettings currentSettings;
  final Function(FilterSettings) onApplyFilters;

  const FilterDrawer({
    super.key,
    required this.currentSettings,
    required this.onApplyFilters,
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late FilterSettings settings;
  final double maxCookTime = 120;

  @override
  void initState() {
    super.initState();
    settings = widget.currentSettings;
  }

  Widget _buildFilterChip(String label, bool selected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      selectedColor: Colors.pink,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
      ),
      onSelected: (bool value) {
        setState(() {
          if (value) {
            settings.dietary.add(label);
          } else {
            settings.dietary.remove(label);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Cook time',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Slider(
                      value: (settings.cookTime ?? 30).toDouble(),
                      min: 0,
                      max: maxCookTime,
                      divisions: 12,
                      label: '${settings.cookTime ?? 30} min',
                      onChanged: (value) {
                        setState(() {
                          settings.cookTime = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Difficulty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Simple'),
                          selected: settings.difficulty == 'Simple',
                          onSelected: (selected) {
                            setState(() {
                              settings.difficulty = selected ? 'Simple' : null;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Medium'),
                          selected: settings.difficulty == 'Medium',
                          onSelected: (selected) {
                            setState(() {
                              settings.difficulty = selected ? 'Medium' : null;
                            });
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Professional'),
                          selected: settings.difficulty == 'Professional',
                          onSelected: (selected) {
                            setState(() {
                              settings.difficulty =
                                  selected ? 'Professional' : null;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            settings = FilterSettings();
                          });
                        },
                        child: const Text('Clear all'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          widget.onApplyFilters(settings);
                          Navigator.pop(context);
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
