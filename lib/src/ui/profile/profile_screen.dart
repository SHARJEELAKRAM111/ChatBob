import 'dart:io';
import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';
import 'package:chatbob/src/ui/auth/providers/session_provider.dart';
import 'package:chatbob/src/ui/profile/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<SessionProvider>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );

    if (picked == null || !mounted) return;

    final userId = context.read<SessionProvider>().user?.id ?? '';
    await context.read<ProfileProvider>().updateProfilePhoto(
      userId,
      File(picked.path),
    );
  }

  Future<void> _saveProfile() async {
    final userId = context.read<SessionProvider>().user?.id ?? '';
    final profileProvider = context.read<ProfileProvider>();

    final nameChanged = await profileProvider.updateName(userId, _nameController.text.trim());
    final bioChanged = await profileProvider.updateBio(userId, _bioController.text.trim());

    if (mounted && (nameChanged || bioChanged)) {
      showToast(context, message: 'Profile updated', status: 'success');
      setState(() => _isEditing = false);
    }
  }

  void _logout() async {
    final userId = context.read<SessionProvider>().user?.id ?? '';
    await context.read<ProfileProvider>().setOffline(userId);
    if (mounted) {
      await context.read<SessionProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final session = context.watch<SessionProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final user = session.user;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('Profile', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: profileProvider.isLoading ? null : _saveProfile,
              child: Text(
                'Save',
                style: tt.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.edit_rounded, color: cs.primary),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(height: AppSpacing.lg.h),
            // Avatar
            GestureDetector(
              onTap: _isEditing ? _pickAndUploadPhoto : null,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56.r,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                        ? Icon(Icons.person, size: 48.sp, color: cs.onPrimaryContainer)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 18.sp,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  if (profileProvider.isUploading)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Name
            if (_isEditing)
              _buildEditField(
                controller: _nameController,
                label: 'Display Name',
                icon: Icons.person_outline,
                cs: cs,
                tt: tt,
              )
            else
              Text(
                user?.name ?? 'No name set',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            SizedBox(height: AppSpacing.sm.h),

            // Email (always read-only)
            Text(
              user?.email ?? '',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Bio
            if (_isEditing)
              _buildEditField(
                controller: _bioController,
                label: 'Bio',
                icon: Icons.info_outline,
                maxLines: 3,
                cs: cs,
                tt: tt,
              )
            else if (user?.bio != null && user!.bio!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bio',
                      style: tt.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      user.bio!,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                    ),
                  ],
                ),
              ),

            SizedBox(height: AppSpacing.xxxl.h),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: Icon(Icons.logout_rounded, color: cs.error),
                label: Text(
                  'Logout',
                  style: tt.labelLarge?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.error.withValues(alpha: 0.3)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md.h),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
          filled: true,
          fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: cs.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
