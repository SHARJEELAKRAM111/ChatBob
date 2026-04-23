import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';

import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/data/repositories/auth_repository.dart';
import 'package:chatbob/src/data/repositories/user_repository_impl.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService = AuthService.instance;
  final UserRepositoryImpl _userRepo = UserRepositoryImpl();

  @override
  Stream<AppUser?> get onAuthStateChanged {
    return _authService.authStateChanges.map((userData) {
      if (userData == null) return null;
      return AppUser(
        id: userData['id'] ?? '',
        email: userData['email'] ?? '',
        name: userData['name'],
        photoUrl: userData['photoUrl'],
      );
    });
  }

  @override
  FutureEither<AppUser> login({
    required String email, 
    required String password,
  }) async {
    final result = await _authService.login(email: email, password: password);
    
    return result.flatMap((userData) {
      if (userData == null) {
        return left(const ServerFailure('Login failed: User record not found'));
      }

      final user = AppUser(
        id: userData['id'], 
        email: userData['email'] ?? email, 
        name: userData['name'],
        photoUrl: userData['photoUrl'],
      );
      
      return right(user);
    });
  }

  @override
  FutureEither<AppUser> signUp({
    required String name, 
    required String email, 
    required String password,
  }) async {
    final result = await _authService.signUp(
      name: name,
      email: email,
      password: password,
    );

    return result.flatMap((userData) {
      if (userData == null) {
        return left(const ServerFailure('Sign up failed: User record corrupted'));
      }

      final user = AppUser(
        id: userData['id'], 
        email: userData['email'] ?? email, 
        name: name,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      // Save user profile to Realtime Database
      _userRepo.saveUserProfile(user);
      
      return right(user);
    });
  }

  @override
  FutureEither<void> forgotPassword({required String email}) {
    return _authService.forgotPassword(email: email);
  }

  @override
  FutureEither<void> logout() {
    return _authService.logout();
  }

  @override
  FutureEither<AppUser?> checkAuthState() async {
    final result = await _authService.getCurrentUser();
    
    return result.map((userData) {
      if (userData == null) return null;

      return AppUser(
        id: userData['id'], 
        email: userData['email'] ?? '', 
        name: userData['name'],
        photoUrl: userData['photoUrl'],
      );
    });
  }
}
