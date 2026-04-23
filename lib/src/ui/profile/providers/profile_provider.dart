import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chatbob/src/data/repositories/user_repository.dart';
import 'package:chatbob/src/data/repositories/storage_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final UserRepository _userRepo;
  final StorageRepository _storageRepo;

  ProfileProvider({
    required UserRepository userRepo,
    required StorageRepository storageRepo,
  })  : _userRepo = userRepo,
        _storageRepo = storageRepo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  /// Update user display name.
  Future<bool> updateName(String userId, String name) async {
    _isLoading = true;
    notifyListeners();

    final result = await _userRepo.updateUserProfile(userId, {'name': name});
    _isLoading = false;
    notifyListeners();

    return result.isRight();
  }

  /// Update user bio.
  Future<bool> updateBio(String userId, String bio) async {
    _isLoading = true;
    notifyListeners();

    final result = await _userRepo.updateUserProfile(userId, {'bio': bio});
    _isLoading = false;
    notifyListeners();

    return result.isRight();
  }

  /// Upload and update profile photo.
  Future<String?> updateProfilePhoto(String userId, File file) async {
    _isUploading = true;
    notifyListeners();

    final uploadResult = await _storageRepo.uploadProfilePhoto(
      userId: userId,
      file: file,
    );

    String? url;
    await uploadResult.fold(
      (failure) async {
        url = null;
      },
      (downloadUrl) async {
        url = downloadUrl;
        await _userRepo.updateUserProfile(userId, {'photoUrl': downloadUrl});
      },
    );

    _isUploading = false;
    notifyListeners();
    return url;
  }

  /// Set up online presence.
  Future<void> setupPresence(String userId) async {
    await _userRepo.setupPresence(userId);
  }

  /// Set user offline.
  Future<void> setOffline(String userId) async {
    await _userRepo.setOnlineStatus(userId, false);
  }
}
