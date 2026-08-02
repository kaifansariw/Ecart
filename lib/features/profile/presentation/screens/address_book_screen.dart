import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../services/supabase_service.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});
  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await SupabaseService.from('addresses').select().eq('user_id', SupabaseService.userId!).order('is_default', ascending: false);
      if (mounted) setState(() { _addresses = List<Map<String, dynamic>>.from(data); _isLoading = false; });
    } catch (_) { if (mounted) setState(() => _isLoading = false); }
  }

  Future<void> _delete(String id) async {
    await SupabaseService.from('addresses').delete().eq('id', id);
    _load();
  }

  void _showAddDialog() {
    final nameC = TextEditingController();
    final addr1C = TextEditingController();
    final cityC = TextEditingController();
    final postalC = TextEditingController();

    showModalBottomSheet(context: context, isScrollControlled: true, shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl))),
      builder: (_) => Padding(padding: EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.xl, bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add Address', style: AppTypography.headingMedium),
          const SizedBox(height: AppSpacing.lg),
          CustomTextField(label: 'Full Name', controller: nameC, hint: 'Recipient name'),
          const SizedBox(height: AppSpacing.md),
          CustomTextField(label: 'Address', controller: addr1C, hint: 'Street address'),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            Expanded(child: CustomTextField(label: 'City', controller: cityC)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: CustomTextField(label: 'Postal Code', controller: postalC, keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: AppSpacing.xl),
          CustomButton(label: 'Save Address', onPressed: () async {
            await SupabaseService.from('addresses').insert({
              'user_id': SupabaseService.userId, 'full_name': nameC.text.trim(),
              'address_line_1': addr1C.text.trim(), 'city': cityC.text.trim(),
              'postal_code': postalC.text.trim(), 'country': 'US',
            });
            if (mounted) { Navigator.pop(context); _load(); }
          }),
        ])));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(child: Column(children: [
        Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Row(children: [
          GestureDetector(onTap: () => context.pop(), child: Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
          const SizedBox(width: AppSpacing.base),
          Text('Addresses', style: AppTypography.headingMedium),
          const Spacer(),
          GestureDetector(onTap: _showAddDialog, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
            child: Text('+ Add', style: AppTypography.labelSmall.copyWith(color: AppColors.textOnAccent, fontWeight: FontWeight.w700)),
          )),
        ])),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
              : _addresses.isEmpty
                  ? Center(child: Text('No addresses yet', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      itemCount: _addresses.length,
                      itemBuilder: (_, i) {
                        final a = _addresses[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md), padding: const EdgeInsets.all(AppSpacing.base),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: a['is_default'] == true ? AppColors.accent : (isDark ? AppColors.borderDark : AppColors.border)),
                          ),
                          child: Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(a['label'] ?? 'Address', style: AppTypography.labelLarge),
                                if (a['is_default'] == true) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 1),
                                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                    child: Text('Default', style: AppTypography.labelSmall.copyWith(color: AppColors.accent, fontSize: 9)),
                                  ),
                                ],
                              ]),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(a['full_name'] ?? '', style: AppTypography.bodyMedium),
                              Text('${a['address_line_1'] ?? ''}, ${a['city'] ?? ''} ${a['postal_code'] ?? ''}', style: AppTypography.bodySmall),
                            ])),
                            GestureDetector(onTap: () => _delete(a['id']), child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20)),
                          ]),
                        );
                      }),
        ),
      ])),
    );
  }
}
