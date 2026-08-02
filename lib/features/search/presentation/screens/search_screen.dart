import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_spacing.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../services/supabase_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final data = await SupabaseService.from('products')
          .select('id, name, price, product_images(url, is_primary)')
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .limit(20);
      if (mounted) setState(() { _results = List<Map<String, dynamic>>.from(data); _isSearching = false; });
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(children: [
                Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _search,
                    style: AppTypography.bodyLarge,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () { _searchController.clear(); setState(() => _results = []); },
                    child: Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 20),
                  ),
              ]),
            ),
          ),
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
                : _results.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.search_rounded, size: 64, color: AppColors.textTertiary),
                        const SizedBox(height: AppSpacing.md),
                        Text(_searchController.text.isEmpty ? 'Search for products' : 'No results found',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
                      ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final p = _results[i];
                          final imgs = p['product_images'] as List? ?? [];
                          final img = imgs.isNotEmpty ? (imgs.firstWhere((x) => x['is_primary'] == true, orElse: () => imgs.first)['url'] ?? '') : '';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: img.isNotEmpty
                                  ? ClipRRect(borderRadius: BorderRadius.circular(AppSpacing.radiusMd), child: Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image_outlined, color: AppColors.textTertiary)))
                                  : Icon(Icons.image_outlined, color: AppColors.textTertiary),
                            ),
                            title: Text(p['name'] ?? '', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                            subtitle: Text('\$${(p['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}', style: AppTypography.labelMedium.copyWith(color: AppColors.accent)),
                            onTap: () => context.push('/products/${p['id']}'),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}
