import '../../imports/imports.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/storage_repository_impl.dart';
import '../../ui/auth/providers/session_provider.dart';
import '../../ui/auth/providers/auth_provider.dart';
import '../../ui/chat/providers/chat_provider.dart';
import '../../ui/contacts/providers/contacts_provider.dart';
import '../../ui/profile/providers/profile_provider.dart';

/// A wrapper to initialize the chosen State Management library.
class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepositoryImpl();
    final chatRepo = ChatRepositoryImpl();
    final userRepo = UserRepositoryImpl();
    final storageRepo = StorageRepositoryImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SessionProvider(repository: authRepo, userRepo: userRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatRepo: chatRepo,
            storageRepo: storageRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ContactsProvider(userRepo: userRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            userRepo: userRepo,
            storageRepo: storageRepo,
          ),
        ),
      ],
      child: child,
    );
  }
}
