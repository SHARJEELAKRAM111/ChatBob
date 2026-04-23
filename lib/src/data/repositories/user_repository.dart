import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/utils/utils.dart';

abstract class UserRepository {
  /// Save user profile to the database (called after signup).
  FutureEither<void> saveUserProfile(AppUser user);

  /// Update user profile fields.
  FutureEither<void> updateUserProfile(String userId, Map<String, dynamic> data);

  /// Get a user by their ID.
  FutureEither<AppUser?> getUserById(String userId);

  /// Search users by email or name.
  FutureEither<List<AppUser>> searchUsers(String query, {required String currentUserId});

  /// Get all users (excluding current user).
  FutureEither<List<AppUser>> getAllUsers({required String currentUserId});

  /// Set user online status.
  FutureEither<void> setOnlineStatus(String userId, bool isOnline);

  /// Set up presence system with onDisconnect.
  Future<void> setupPresence(String userId);

  /// Stream a user's online status.
  Stream<bool> streamUserOnlineStatus(String userId);
}
