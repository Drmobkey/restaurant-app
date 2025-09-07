import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/search_ui_provider.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  void _performSearch(BuildContext context, String query) {
    if (query.trim().isEmpty) return;

    final searchUIProvider = context.read<SearchUIProvider>();
    searchUIProvider.setQuery(query);

    context.read<RestaurantProvider>().searchRestaurants(query);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchUIProvider(),
      child: Consumer3<ThemeProvider, RestaurantProvider, SearchUIProvider>(
        builder:
            (
              context,
              themeProvider,
              restaurantProvider,
              searchUIProvider,
              child,
            ) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Cari Restaurant'),
                  actions: [
                    IconButton(
                      icon: Icon(
                        themeProvider.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: themeProvider.toggleTheme,
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: searchUIProvider.searchController,
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama restaurant...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon:
                              searchUIProvider.searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchUIProvider.clearSearch();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (query) => _performSearch(context, query),
                        onChanged: (value) {
                          // Trigger rebuild untuk suffixIcon
                          searchUIProvider.notifyListeners();
                        },
                      ),
                    ),

                    // Search Results
                    Expanded(child: _buildSearchResults(restaurantProvider)),
                  ],
                ),
              );
            },
      ),
    );
  }

  Widget _buildSearchResults(RestaurantProvider provider) {
    return provider.searchState.when(
      initial: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Cari restaurant favoritmu!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      loading: () => const LoadingWidget(),
      success: (restaurants) {
        if (restaurants.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Restaurant tidak ditemukan',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            return RestaurantCard(restaurant: restaurants[index]);
          },
        );
      },
      error: (message) => CustomErrorWidget(
        message: message,
        onRetry: () {
          // Implementasi retry jika diperlukan
        },
      ),
    );
  }
}
