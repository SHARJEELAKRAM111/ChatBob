import 'dart:io';
import 'package:chatbob/src/data/repositories/storage_repository.dart';
import 'package:chatbob/src/services/firebase_storage_service.dart';
import 'package:chatbob/src/utils/utils.dart';

class StorageRepositoryImpl implements StorageRepository {
  final FirebaseStorageService _storage = FirebaseStorageService.instance;

  @override
  FutureEither<String> uploadChatImage({
    required String chatId,
    required File file,
    void Function(double)? onProgress,
  }) async {
    return runTask(() async {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'chats/$chatId/images/$fileName';
      return await _storage.uploadFile(
        path: path,
        file: file,
        contentType: 'image/jpeg',
        onProgress: onProgress,
      );
    });
  }

  @override
  FutureEither<String> uploadChatFile({
    required String chatId,
    required File file,
    required String fileName,
    void Function(double)? onProgress,
  }) async {
    return runTask(() async {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'chats/$chatId/files/${timestamp}_$fileName';
      return await _storage.uploadFile(
        path: path,
        file: file,
        onProgress: onProgress,
      );
    });
  }

  @override
  FutureEither<String> uploadProfilePhoto({
    required String userId,
    required File file,
  }) async {
    return runTask(() async {
      final path = 'profiles/$userId/avatar.jpg';
      return await _storage.uploadFile(
        path: path,
        file: file,
        contentType: 'image/jpeg',
      );
    });
  }

  @override
  FutureEither<void> deleteFile(String url) async {
    return runTask(() async {
      // Firebase Storage URLs can be used to get a reference
      // but we need the path. For now, this is a placeholder.
      // In practice, you'd store the storage path alongside the URL.
    });
  }
}
