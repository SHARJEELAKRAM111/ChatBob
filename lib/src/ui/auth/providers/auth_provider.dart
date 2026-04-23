import 'package:chatbob/src/imports/core_imports.dart';

import 'package:chatbob/src/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void login(
      {required BuildContext context,
      required String email,
      required String password}) async {
    _setLoading(true);

    final result = await _repository.login(email: email, password: password);

    _setLoading(false);
    result.fold(
      (failure) {
        showToast(context, message: failure.message, status: 'error');
      },
      (user) {
        // Navigation is handled by SessionListenerWrapper
      },
    );
  }

  void signUp(
      {required BuildContext context,
      required String name,
      required String email,
      required String password}) async {
    _setLoading(true);

    final result =
        await _repository.signUp(name: name, email: email, password: password);

    _setLoading(false);
    result.fold(
      (failure) {
        showToast(context, message: failure.message, status: 'error');
      },
      (user) {
        // Navigation is handled by SessionListenerWrapper
      },
    );
  }

  void forgotPassword(
      {required BuildContext context, required String email}) async {
    _setLoading(true);

    final result = await _repository.forgotPassword(email: email);

    _setLoading(false);
    result.fold(
      (failure) {
        showToast(context, message: failure.message, status: 'error');
      },
      (success) {
        showToast(context,
            message: 'Password reset link sent successfully',
            status: 'success');
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      },
    );
  }
}
