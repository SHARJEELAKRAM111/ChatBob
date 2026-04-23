import 'dart:io';
import 'package:chatbob/src/utils/utils.dart';

abstract class StorageRepository {
  /// Upload a chat image and return the download URL.
  FutureEither<String> uploadChatImage({
    required String chatId,
    required File file,
    void Function(double)? onProgress,
  });

  /// Upload a chat file and return the download URL.
  FutureEither<String> uploadChatFile({
    required String chatId,
    required File file,
    required String fileName,
    void Function(double)? onProgress,
  });

  /// Upload a profile photo and return the download URL.
  FutureEither<String> uploadProfilePhoto({
    required String userId,
    required File file,
  });

  /// Delete a file by its storage URL.
  FutureEither<void> deleteFile(String url);
}
