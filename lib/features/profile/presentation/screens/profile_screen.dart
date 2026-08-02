import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../services/supabase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!SupabaseService.isAuthenticated) return;
    try {
      final data = await SupabaseService.from('profiles').select().eq('id', SupabaseService.userId!).single();
      if (mounted) setState(() => _profile = data);
    } catch (_) {}
  }

  Future<void> _signOut() async {
    await SupabaseService.auth.signOut();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final email = SupabaseService.currentUser?.email ?? '';
    final name = _profile?['full_name'] ?? 'User';

    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(children: [
        const SizedBox(height: AppSpacing.lg),
        // Avatar
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
          child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: AppTypography.displaySmall.copyWith(color: Colors.white))),
        ),
        const SizedBox(height: AppSpacing.base),
        Text(name, style: AppTypography.headingMedium),
        Text(email, style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.xxl),

        _ProfileTile(icon: Icons.person_outline_rounded, title: 'Edit Profile', onTap: () => context.push('/profile/edit')),
        _ProfileTile(icon: Icons.location_on_outlined, title: 'Addresses', onTap: () => context.push('/profile/addresses')),
        _ProfileTile(icon: Icons.receipt_long_outlined, title: 'Order History', onTap: () => context.push('/orders')),
        _ProfileTile(icon: Icons.favorite_outline_rounded, title: 'Wishlist', onTap: () => context.go('/wishlist')),
        const SizedBox(height: AppSpacing.xl),
        _ProfileTile(icon: Icons.logout_rounded, title: 'Sign Out', onTap: _signOut, isDestructive: true),
      ]))),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap; final bool isDestructive;
  const _ProfileTile({required this.icon, required this.title, required this.onTap, this.isDestructive = false});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive ? AppColors.error : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 0.5),
        ),
        child: Row(children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: AppSpacing.md),
          Text(title, style: AppTypography.bodyLarge.copyWith(color: color)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
        ]),
      ),
    );
  }
}
