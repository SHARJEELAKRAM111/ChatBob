import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/app_config.dart';

/// Service for uploading/downloading files from Firebase Storage.
class FirebaseStorageService {
  FirebaseStorageService._();
  static final FirebaseStorageService instance = FirebaseStorageService._();

  FirebaseStorage get _storage => AppConfig.storage;

  /// Upload a file to [path] in Firebase Storage.
  /// Returns the download URL on success.
  /// [onProgress] reports upload progress as a 0.0–1.0 double.
  Future<String> uploadFile({
    required String path,
    required File file,
    String? contentType,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref(path);
    final metadata = contentType != null ? SettableMetadata(contentType: contentType) : null;
    final uploadTask = ref.putFile(file, metadata);

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    await uploadTask;
    return await ref.getDownloadURL();
  }

  /// Upload raw bytes to [path] in Firebase Storage.
  Future<String> uploadBytes({
    required String path,
    required List<int> bytes,
    String? contentType,
  }) async {
    final ref = _storage.ref(path);
    final metadata = contentType != null ? SettableMetadata(contentType: contentType) : null;
    await ref.putData(bytes as dynamic, metadata);
    return await ref.getDownloadURL();
  }

  /// Get the download URL for a file at [path].
  Future<String> getDownloadUrl(String path) async {
    return await _storage.ref(path).getDownloadURL();
  }

  /// Delete a file at [path].
  Future<void> deleteFile(String path) async {
    await _storage.ref(path).delete();
  }
}
