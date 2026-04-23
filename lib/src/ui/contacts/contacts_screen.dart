import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';
import 'package:chatbob/src/data/models/user_model.dart';
import 'package:chatbob/src/ui/auth/providers/session_provider.dart';
import 'package:chatbob/src/ui/chat/providers/chat_provider.dart';
import 'package:chatbob/src/ui/contacts/providers/contacts_provider.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userId = context.read<SessionProvider>().user?.id ?? '';
    context.read<ContactsProvider>().loadAllUsers(userId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat(AppUser otherUser) async {
    final session = context.read<SessionProvider>();
    final currentUser = session.user;
    if (currentUser == null) return;

    final chatProvider = context.read<ChatProvider>();
    final chat = await chatProvider.getOrCreateChat(
      currentUser: currentUser,
      otherUser: otherUser,
    );

    if (chat != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.chat,
        arguments: {
          'chatId': chat.id,
          'otherUserId': otherUser.id,
          'otherUserName': otherUser.name ?? otherUser.email,
          'otherUserPhoto': otherUser.photoUrl,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final contactsProvider = context.watch<ContactsProvider>();
    final currentUserId = context.read<SessionProvider>().user?.id ?? '';

    final displayUsers = contactsProvider.searchQuery.isNotEmpty
        ? contactsProvider.searchResults
        : contactsProvider.users;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'New Chat',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(12.w),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _searchController,
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  hintStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: cs.onSurfaceVariant),
                          onPressed: () {
                            _searchController.clear();
                            contactsProvider.clearSearch();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onChanged: (value) {
                  contactsProvider.searchUsers(
                    value,
                    currentUserId: currentUserId,
                  );
                },
              ),
            ),
          ),
          // User list
          Expanded(
            child: contactsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayUsers.isEmpty
                    ? _buildEmptyState(cs, tt)
                    : ListView.builder(
                        itemCount: displayUsers.length,
                        itemBuilder: (context, index) {
                          final user = displayUsers[index];
                          return _UserTile(
                            user: user,
                            onTap: () => _startChat(user),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme cs, TextTheme tt) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 48.sp,
            color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: AppSpacing.md.h),
          Text(
            'No users found',
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback onTap;

  const _UserTile({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return ListTile(
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: cs.primaryContainer,
            backgroundImage:
                user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
            child: user.photoUrl == null
                ? Text(
                    (user.name ?? user.email).isNotEmpty
                        ? (user.name ?? user.email)[0].toUpperCase()
                        : '?',
                    style: tt.titleMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          if (user.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user.name ?? user.email,
        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        user.bio ?? user.email,
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
