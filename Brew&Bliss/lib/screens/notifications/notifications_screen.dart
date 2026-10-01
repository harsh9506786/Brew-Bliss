import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/fade_slide_in.dart';

class _NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  bool unread;

  _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      icon: Icons.local_shipping_outlined,
      title: 'Order out for delivery',
      subtitle: 'Your Cappuccino & Caffe Latte are on the way!',
      time: '5m ago',
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.local_offer_outlined,
      title: 'Weekend Special',
      subtitle: 'Get 20% off on all coffee orders this weekend.',
      time: '2h ago',
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.stars_outlined,
      title: 'Reward points added',
      subtitle: 'You earned 15 points from your last order.',
      time: '1d ago',
      unread: true,
    ),
    _NotificationItem(
      icon: Icons.check_circle_outline,
      title: 'Order delivered',
      subtitle: 'Your order #1042 was delivered. Enjoy!',
      time: '2d ago',
    ),
    _NotificationItem(
      icon: Icons.favorite_border,
      title: 'Back in stock',
      subtitle: 'Cold Brew is back on the menu.',
      time: '4d ago',
    ),
  ];

  int get _unreadCount => _notifications.where((n) => n.unread).length;

  void _markAllRead() {
    HapticFeedback.selectionClick();
    setState(() {
      for (final n in _notifications) {
        n.unread = false;
      }
    });
  }

  void _markRead(_NotificationItem item) {
    if (!item.unread) return;
    setState(() => item.unread = false);
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
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return FadeSlideIn(
                          index: index,
                          child: _buildTile(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HEADER
  // --------------------------------------------------

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications', style: AppTextStyles.heading),
                const SizedBox(height: 2),
                Text(
                  _unreadCount > 0 ? '$_unreadCount new' : 'All caught up',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark all read',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // TILE
  // --------------------------------------------------

  Widget _buildTile(_NotificationItem item) {
    return GestureDetector(
      onTap: () => _markRead(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.unread
              ? AppColors.cream.withOpacity(0.55)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.unread
                ? AppColors.primary.withOpacity(0.25)
                : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(item.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight:
                                item.unread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(item.time,
                          style:
                              AppTextStyles.bodySmall.copyWith(fontSize: 9.5)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(height: 1.3),
                  ),
                ],
              ),
            ),
            if (item.unread)
              Padding(
                padding: const EdgeInsets.only(left: 6, top: 3),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // EMPTY STATE
  // --------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none,
                size: 60, color: AppColors.mediumBrown),
            const SizedBox(height: 16),
            Text('No notifications', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 6),
            Text(
              'We\'ll let you know when\nsomething new comes up.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
