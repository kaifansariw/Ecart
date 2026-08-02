import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await SupabaseService.from('profiles').select().eq('id', SupabaseService.userId!).single();
      _nameController.text = data['full_name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await SupabaseService.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', SupabaseService.userId!);
      if (mounted) context.pop();
    } catch (_) {}
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  void dispose() { _nameController.dispose(); _phoneController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)));
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Row(children: [
          GestureDetector(onTap: () => context.pop(), child: Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
          const SizedBox(width: AppSpacing.base),
          Text('Edit Profile', style: AppTypography.headingMedium),
        ])),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Column(children: [
          CustomTextField(label: 'Full Name', controller: _nameController, prefixIcon: Icons.person_outline_rounded),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(label: 'Phone', controller: _phoneController, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
          const SizedBox(height: AppSpacing.xxl),
          CustomButton(label: 'Save Changes', onPressed: _isSaving ? null : _save, isLoading: _isSaving),
        ]))),
      ])),
    );
  }
}
