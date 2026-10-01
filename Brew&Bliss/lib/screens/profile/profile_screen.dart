import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/fade_slide_in.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = 'Harshvardhan Sharma';
  String email = 'harshvardhan@brewbliss.com';
  String avatarEmoji = '🧑‍💻';

  bool pushNotifications = true;
  bool orderUpdatesSms = false;
  bool darkMode = false;

  final List<String> avatarOptions = const [
    '🧑‍💻',
    '☕',
    '🐻',
    '🎧',
    '🚴',
    '📚',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Text('Profile', style: AppTextStyles.heading),
            const SizedBox(height: 18),
            FadeSlideIn(index: 0, child: _buildProfileHeader()),
            const SizedBox(height: 18),
            FadeSlideIn(index: 1, child: _buildStatsRow()),
            const SizedBox(height: 22),
            FadeSlideIn(
              index: 2,
              child: _buildSection(
                title: 'Account',
                tiles: [
                  _tile(
                    icon: Icons.edit_rounded,
                    label: 'Edit Profile',
                    onTap: _openEditProfile,
                  ),
                  _tile(
                    icon: Icons.location_on_outlined,
                    label: 'My Addresses',
                    onTap: () => _snack('Opening My Addresses'),
                  ),
                  _tile(
                    icon: Icons.credit_card_rounded,
                    label: 'Payment Methods',
                    onTap: () => _snack('Opening Payment Methods'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              index: 3,
              child: _buildSection(
                title: 'Preferences',
                tiles: [
                  _switchTile(
                    icon: Icons.notifications_none_rounded,
                    label: 'Push Notifications',
                    value: pushNotifications,
                    onChanged: (v) => setState(() => pushNotifications = v),
                  ),
                  _switchTile(
                    icon: Icons.sms_outlined,
                    label: 'Order Updates via SMS',
                    value: orderUpdatesSms,
                    onChanged: (v) => setState(() => orderUpdatesSms = v),
                  ),
                  _switchTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Dark Mode',
                    value: darkMode,
                    onChanged: (v) => setState(() => darkMode = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FadeSlideIn(
              index: 4,
              child: _buildSection(
                title: 'Support',
                tiles: [
                  _tile(
                    icon: Icons.help_outline_rounded,
                    label: 'Help Center',
                    onTap: () => _snack('Opening Help Center'),
                  ),
                  _tile(
                    icon: Icons.mail_outline_rounded,
                    label: 'Contact Us',
                    onTap: () => _snack('Opening Contact Us'),
                  ),
                  _tile(
                    icon: Icons.info_outline_rounded,
                    label: 'About Brew & Bliss',
                    onTap: () => _snack('Brew & Bliss v1.0.0'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            FadeSlideIn(index: 5, child: _buildLogoutButton()),
          ],
        ),
      ),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _openAvatarPicker,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    avatarEmoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.darkBrown,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.heading.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Gold Member',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choose an avatar', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: avatarOptions.map((emoji) {
                  final selected = emoji == avatarEmoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() => avatarEmoji = emoji);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.cream,
                        shape: BoxShape.circle,
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditProfile() {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Full name',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                    setState(() {
                      name = nameController.text.trim().isEmpty
                          ? name
                          : nameController.text.trim();
                      email = emailController.text.trim().isEmpty
                          ? email
                          : emailController.text.trim();
                    });
                    Navigator.pop(context);
                    _snack('Profile updated');
                  },
                  child: Text('Save Changes', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --------------------------------------------------
  // STATS
  // --------------------------------------------------

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard(icon: Icons.receipt_long_rounded, value: 24, label: 'Orders')),
        const SizedBox(width: 10),
        Expanded(child: _statCard(icon: Icons.stars_rounded, value: 320, label: 'Points')),
        const SizedBox(width: 10),
        Expanded(child: _statCard(icon: Icons.favorite_rounded, value: 8, label: 'Favorites')),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required int value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 6),
          CountUpText(
            value: value,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 9.5)),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // SETTINGS SECTIONS
  // --------------------------------------------------

  Widget _buildSection({required String title, required List<Widget> tiles}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mediumBrown,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i != tiles.length - 1)
                  const Divider(height: 1, color: AppColors.border, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: AppColors.darkBrown),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColors.mediumBrown,
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.darkBrown),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // LOGOUT
  // --------------------------------------------------

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(
          'Logout',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.redAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Log out?', style: AppTextStyles.sectionTitle),
          content: Text(
            'You\'ll need to sign in again to place orders.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _snack('Logged out successfully');
              },
              child: Text('Logout', style: AppTextStyles.button),
            ),
          ],
        );
      },
    );
  }
}