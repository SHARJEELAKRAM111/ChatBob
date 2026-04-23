import 'package:chatbob/src/imports/core_imports.dart';
import 'package:chatbob/src/imports/packages_imports.dart';
import 'package:chatbob/src/ui/auth/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<AuthProvider>().signUp(
          context: context,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl.h),

                // ── Logo & Header ──
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [cs.tertiary, cs.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: cs.tertiary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 36.sp,
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),
                Text(
                  'auth.create_account'.tr(),
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  'auth.create_account_subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                SizedBox(height: AppSpacing.xxxl.h),

                // ── Form ──
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _nameController,
                        enabled: !isLoading,
                        label: 'auth.name'.tr(),
                        prefixIcon: Icon(Icons.person_outline, color: cs.onSurfaceVariant),
                        validator: (v) => AppUtils.isBlank(v) ? 'auth.name_required'.tr() : null,
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      AppTextField(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        label: 'auth.email'.tr(),
                        prefixIcon: Icon(Icons.email_outlined, color: cs.onSurfaceVariant),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) return 'auth.email_required'.tr();
                          if (!AppUtils.isValidEmail(v!)) return 'auth.email_invalid'.tr();
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      AppTextField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        label: 'auth.password'.tr(),
                        obscureText: _obscurePassword,
                        prefixIcon: Icon(Icons.lock_outline, color: cs.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: cs.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) return 'auth.password_required'.tr();
                          if (v!.length < 6) return 'auth.password_too_short'.tr();
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      AppTextField(
                        controller: _confirmPasswordController,
                        enabled: !isLoading,
                        label: 'auth.confirm_password'.tr(),
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icon(Icons.lock_outline, color: cs.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: cs.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (v) {
                          if (AppUtils.isBlank(v)) return 'auth.confirm_password_required'.tr();
                          if (v != _passwordController.text) return 'auth.passwords_do_not_match'.tr();
                          return null;
                        },
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: FilledButton(
                          onPressed: isLoading ? null : _handleSignup,
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : Text(
                                  'Create Account',
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxxl.h),

                // ── Social Login ──
                Row(
                  children: [
                    Expanded(child: Divider(color: cs.outlineVariant)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Or sign up with',
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                    Expanded(child: Divider(color: cs.outlineVariant)),
                  ],
                ),
                SizedBox(height: AppSpacing.lg.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16.w,
                  children: [
                    _SocialButton(
                      color: const Color(0xFFEA4335),
                      child: SvgPicture.asset(AppAssets.googleIcon, width: 22.w),
                      onTap: () {},
                    ),
                    _SocialButton(
                      color: const Color(0xFF4285F4),
                      child: SvgPicture.asset(AppAssets.facebookIcon, width: 22.w),
                      onTap: () {},
                    ),
                    _SocialButton(
                      color: cs.onSurface,
                      child: SvgPicture.asset(AppAssets.appleIcon, width: 22.w),
                      onTap: () {},
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xxxl.h),

                // ── Login Link ──
                InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    child: RichText(
                      text: TextSpan(
                        text: 'auth.already_have_account'.tr(),
                        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Color color;
  final Widget child;
  final VoidCallback onTap;

  const _SocialButton({
    required this.color,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: SizedBox(
          width: 56.w,
          height: 56.w,
          child: Center(child: child),
        ),
      ),
    );
  }
}
