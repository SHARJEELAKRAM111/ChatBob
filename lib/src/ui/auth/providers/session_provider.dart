import 'dart:async';
import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/data/repositories/auth_repository.dart';
import 'package:chatbob/src/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final UserRepository _userRepo;
  StreamSubscription<AppUser?>? _authSub;

  SessionStatus _status = SessionStatus.unknown;
  AppUser? _user;

  SessionStatus get status => _status;
  AppUser? get user => _user;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  SessionProvider({
    required AuthRepository repository,
    required UserRepository userRepo,
  })  : _repository = repository,
        _userRepo = userRepo {
    _init();
  }

  Future<void> _init() async {
    final result = await _repository.checkAuthState();
    await result.fold(
      (_) async {
        _status = SessionStatus.unauthenticated;
        notifyListeners();
      },
      (user) async {
        if (user != null) {
          // Fetch full profile from RTDB to get name, bio, etc.
          _user = await _fetchFullProfile(user);
          _status = SessionStatus.authenticated;
        } else {
          _status = SessionStatus.unauthenticated;
        }
        notifyListeners();
      },
    );

    _authSub = _repository.onAuthStateChanged.listen((user) async {
      if (user != null) {
        _user = await _fetchFullProfile(user);
        _status = SessionStatus.authenticated;
      } else {
        _user = null;
        _status = SessionStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  /// Fetch the full user profile from RTDB.
  /// Falls back to the Firebase Auth user if RTDB lookup fails.
  Future<AppUser> _fetchFullProfile(AppUser authUser) async {
    final result = await _userRepo.getUserById(authUser.id);
    return result.fold(
      (_) => authUser, // fallback to auth data
      (rtdbUser) => rtdbUser ?? authUser, // use RTDB data if available
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
