import 'package:flutter/material.dart';
import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/data/repositories/user_repository.dart';

class ContactsProvider extends ChangeNotifier {
  final UserRepository _userRepo;

  ContactsProvider({required UserRepository userRepo}) : _userRepo = userRepo;

  List<AppUser> _users = [];
  List<AppUser> get users => _users;

  List<AppUser> _searchResults = [];
  List<AppUser> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Load all users (excluding current user).
  Future<void> loadAllUsers(String currentUserId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _userRepo.getAllUsers(currentUserId: currentUserId);
    result.fold(
      (failure) {
        _users = [];
      },
      (users) {
        _users = users;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Search users by query.
  Future<void> searchUsers(String query, {required String currentUserId}) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _isSearching = false;
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    final result = await _userRepo.searchUsers(query, currentUserId: currentUserId);
    result.fold(
      (failure) {
        _searchResults = [];
      },
      (users) {
        _searchResults = users;
      },
    );

    _isSearching = false;
    notifyListeners();
  }

  /// Clear search results.
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }
}
