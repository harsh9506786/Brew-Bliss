import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/fade_slide_in.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _orderUpdates = true;
  bool _offers = true;
  bool _darkMode = false;
  String _language = 'English';

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pickLanguage() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: AppColors.background,
        title: Text('Language', style: AppTextStyles.sectionTitle),
        children: ['English', 'हिन्दी'].map((l) {
          return SimpleDialogOption(
            onPressed: () {
              setState(() => _language = l);
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Expanded(child: Text(l, style: AppTextStyles.bodyMedium)),
                if (l == _language)
                  const Icon(Icons.check_rounded, color: AppColors.primary),
              ],
            ),
          );
        }).toList(),
      ),
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  FadeSlideIn(
                    index: 0,
                    child: _section('Notifications', [
                      _switchTile(
                        icon: Icons.local_shipping_rounded,
                        label: 'Order updates',
                        value: _orderUpdates,
                        onChanged: (v) => setState(() => _orderUpdates = v),
                      ),
                      _switchTile(
                        icon: Icons.local_offer_rounded,
                        label: 'Offers & promotions',
                        value: _offers,
                        onChanged: (v) => setState(() => _offers = v),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    index: 1,
                    child: _section('Preferences', [
                      _navTile(
                        icon: Icons.language_rounded,
                        label: 'Language',
                        trailing: _language,
                        onTap: _pickLanguage,
                      ),
                      _switchTile(
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark mode',
                        value: _darkMode,
                        onChanged: (v) {
                          setState(() => _darkMode = v);
                          _snack('Dark theme abhi app me add nahi hui hai');
                        },
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    index: 2,
                    child: _section('Account', [
                      _navTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change password',
                        onTap: () => _snack('Opening Change Password'),
                      ),
                      _navTile(
                        icon: Icons.privacy_tip_outlined,
                        label: 'Privacy policy',
                        onTap: () => _snack('Opening Privacy Policy'),
                      ),
                      _navTile(
                        icon: Icons.description_outlined,
                        label: 'Terms & conditions',
                        onTap: () => _snack('Opening Terms'),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    index: 3,
                    child: _section('About', [
                      _navTile(
                        icon: Icons.info_outline_rounded,
                        label: 'About Brew & Bliss',
                        trailing: 'v1.0.0',
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: 'Brew & Bliss',
                          applicationVersion: '1.0.0',
                        ),
                      ),
                    ]),
                  ),
                ],
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
              Text('Settings', style: AppTextStyles.heading),
              const SizedBox(height: 2),
              Text('Preferences & account', style: AppTextStyles.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumBrown,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 19, color: AppColors.primary),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _iconBox(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? trailing,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            _iconBox(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            if (trailing != null)
              Text(trailing, style: AppTextStyles.bodySmall),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: AppColors.mediumBrown),
          ],
        ),
      ),
    );
  }
}
