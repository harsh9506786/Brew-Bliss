import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/fade_slide_in.dart';

class _Address {
  String label;
  String line;
  bool isDefault;

  _Address({required this.label, required this.line, this.isDefault = false});
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final List<_Address> _addresses = [
    _Address(
      label: 'Home',
      line: 'Flat 12, Green Park Colony, Main Road',
      isDefault: true,
    ),
    _Address(label: 'Work', line: '3rd Floor, Tech Hub, Business Park'),
  ];

  IconData _iconFor(String label) {
    switch (label) {
      case 'Home':
        return Icons.home_rounded;
      case 'Work':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  void _setDefault(_Address address) {
    setState(() {
      for (final a in _addresses) {
        a.isDefault = a == address;
      }
    });
  }

  void _delete(_Address address) {
    setState(() {
      _addresses.remove(address);
      if (_addresses.isNotEmpty && !_addresses.any((a) => a.isDefault)) {
        _addresses.first.isDefault = true;
      }
    });
  }

  void _openEditor([_Address? existing]) {
    String label = existing?.label ?? 'Home';
    final controller = TextEditingController(text: existing?.line ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'Add Address' : 'Edit Address',
                    style: AppTextStyles.sectionTitle,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: ['Home', 'Work', 'Other'].map((l) {
                      final selected = l == label;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(l),
                          selected: selected,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.cream,
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color:
                                selected ? Colors.white : AppColors.darkBrown,
                          ),
                          onSelected: (_) => setSheetState(() => label = l),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'House no, street, area, pincode',
                      filled: true,
                      fillColor: AppColors.cream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isEmpty) return;

                        setState(() {
                          if (existing == null) {
                            _addresses.add(_Address(
                              label: label,
                              line: text,
                              isDefault: _addresses.isEmpty,
                            ));
                          } else {
                            existing.label = label;
                            existing.line = text;
                          }
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: Text('Save', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _addresses.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) => FadeSlideIn(
                        index: index,
                        child: _buildCard(_addresses[index]),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add_rounded, color: Colors.white),
                  label: Text('Add new address', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 18, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.darkBrown),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Addresses', style: AppTextStyles.heading),
              const SizedBox(height: 2),
              Text('Manage delivery locations', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(_Address address) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.border,
          width: address.isDefault ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_iconFor(address.label),
                size: 21, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.label, style: AppTextStyles.bodyMedium),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DEFAULT',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(address.line, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.mediumBrown),
            onSelected: (value) {
              if (value == 'default') _setDefault(address);
              if (value == 'edit') _openEditor(address);
              if (value == 'delete') _delete(address);
            },
            itemBuilder: (_) => [
              if (!address.isDefault)
                const PopupMenuItem(
                    value: 'default', child: Text('Set as default')),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: const BoxDecoration(
              color: AppColors.cream,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_off_rounded,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('No addresses saved', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text('Add one to get faster delivery', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}