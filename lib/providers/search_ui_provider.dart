import 'package:flutter/material.dart';

class SearchUIProvider extends ChangeNotifier {
  String _currentQuery = '';
  final TextEditingController _searchController = TextEditingController();

  String get currentQuery => _currentQuery;
  TextEditingController get searchController => _searchController;

  void setQuery(String query) {
    _currentQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _currentQuery = '';
    _searchController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
