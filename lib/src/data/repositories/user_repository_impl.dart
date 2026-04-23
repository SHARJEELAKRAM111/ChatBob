import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/data/repositories/user_repository.dart';
import 'package:chatbob/src/services/realtime_db_service.dart';
import 'package:chatbob/src/utils/utils.dart';

class UserRepositoryImpl implements UserRepository {
  final RealtimeDbService _db = RealtimeDbService.instance;

  @override
  FutureEither<void> saveUserProfile(AppUser user) async {
    return runTask(() async {
      await _db.write('users/${user.id}', user.toMap());
    });
  }

  @override
  FutureEither<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    return runTask(() async {
      await _db.update('users/$userId', data);
    });
  }

  @override
  FutureEither<AppUser?> getUserById(String userId) async {
    return runTask(() async {
      final snapshot = await _db.read('users/$userId');
      if (!snapshot.exists || snapshot.value == null) return null;
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return AppUser.fromMap(data);
    });
  }

  @override
  FutureEither<List<AppUser>> searchUsers(String query, {required String currentUserId}) async {
    return runTask(() async {
      final snapshot = await _db.read('users');
      if (!snapshot.exists || snapshot.value == null) return <AppUser>[];

      final usersMap = Map<String, dynamic>.from(snapshot.value as Map);
      final lowerQuery = query.toLowerCase();

      final users = <AppUser>[];
      for (final entry in usersMap.entries) {
        if (entry.key == currentUserId) continue;
        final userData = Map<String, dynamic>.from(entry.value as Map);
        final user = AppUser.fromMap(userData);
        final nameMatch = (user.name?.toLowerCase() ?? '').contains(lowerQuery);
        final emailMatch = user.email.toLowerCase().contains(lowerQuery);
        if (nameMatch || emailMatch) {
          users.add(user);
        }
      }
      return users;
    });
  }

  @override
  FutureEither<List<AppUser>> getAllUsers({required String currentUserId}) async {
    return runTask(() async {
      final snapshot = await _db.read('users');
      if (!snapshot.exists || snapshot.value == null) return <AppUser>[];

      final usersMap = Map<String, dynamic>.from(snapshot.value as Map);
      final users = <AppUser>[];
      for (final entry in usersMap.entries) {
        if (entry.key == currentUserId) continue;
        final userData = Map<String, dynamic>.from(entry.value as Map);
        users.add(AppUser.fromMap(userData));
      }
      return users;
    });
  }

  @override
  FutureEither<void> setOnlineStatus(String userId, bool isOnline) async {
    return runTask(() async {
      await _db.update('users/$userId', {
        'isOnline': isOnline,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  @override
  Future<void> setupPresence(String userId) async {
    // When the client disconnects, set offline status
    _db.onDisconnect('users/$userId').update({
      'isOnline': false,
      'lastSeen': RealtimeDbService.serverTimestamp,
    });

    // Set online now
    await _db.update('users/$userId', {
      'isOnline': true,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Stream<bool> streamUserOnlineStatus(String userId) {
    return _db.stream('users/$userId/isOnline').map((event) {
      return event.snapshot.value == true;
    });
  }
}
