import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../config/app_config.dart';

/// Thin wrapper around Firebase Realtime Database for CRUD + streams.
class RealtimeDbService {
  RealtimeDbService._();
  static final RealtimeDbService instance = RealtimeDbService._();

  FirebaseDatabase get _db => AppConfig.realtimeDb;

  /// Get a database reference at [path].
  DatabaseReference ref(String path) => _db.ref(path);

  /// Write data at [path]. Overwrites existing data.
  /// Accepts any JSON-serializable value (Map, List, String, int, bool, null).
  Future<void> write(String path, Object? data) async {
    await _db.ref(path).set(data);
  }

  /// Update specific fields at [path] without overwriting siblings.
  Future<void> update(String path, Map<String, dynamic> data) async {
    await _db.ref(path).update(data);
  }

  /// Delete data at [path].
  Future<void> delete(String path) async {
    await _db.ref(path).remove();
  }

  /// Read data once at [path]. Returns null if no data exists.
  Future<DataSnapshot> read(String path) async {
    return await _db.ref(path).get();
  }

  /// Push a new child node at [path] with auto-generated key.
  /// Returns the generated key.
  Future<String> push(String path, Map<String, dynamic> data) async {
    final newRef = _db.ref(path).push();
    await newRef.set(data);
    return newRef.key!;
  }

  /// Stream real-time changes at [path].
  Stream<DatabaseEvent> stream(String path) {
    return _db.ref(path).onValue;
  }

  /// Stream child added events at [path].
  Stream<DatabaseEvent> onChildAdded(String path) {
    return _db.ref(path).onChildAdded;
  }

  /// Stream child changed events at [path].
  Stream<DatabaseEvent> onChildChanged(String path) {
    return _db.ref(path).onChildChanged;
  }

  /// Stream child removed events at [path].
  Stream<DatabaseEvent> onChildRemoved(String path) {
    return _db.ref(path).onChildRemoved;
  }

  /// Query data at [path] ordered by [child], limited to [limit] items.
  Query queryOrdered(String path, {required String orderByChild, int? limitToLast, int? limitToFirst}) {
    Query query = _db.ref(path).orderByChild(orderByChild);
    if (limitToLast != null) query = query.limitToLast(limitToLast);
    if (limitToFirst != null) query = query.limitToFirst(limitToFirst);
    return query;
  }

  /// Set up onDisconnect behavior for a path.
  OnDisconnect onDisconnect(String path) {
    return _db.ref(path).onDisconnect();
  }

  /// Server timestamp placeholder for ordering.
  static Object get serverTimestamp => ServerValue.timestamp;
}
