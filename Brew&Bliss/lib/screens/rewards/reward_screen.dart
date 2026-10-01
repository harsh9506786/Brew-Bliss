import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/fade_slide_in.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _Reward {
  final String title;
  final String description;
  final int cost;
  final IconData icon;

  const _Reward({
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
  });
}

class _RewardsScreenState extends State<RewardsScreen> {
  int points = 320;
  bool _copied = false;

  final List<_Reward> rewards = const [
    _Reward(
      title: 'Free Cappuccino',
      description: 'Any size, any milk option',
      cost: 150,
      icon: Icons.coffee_rounded,
    ),
    _Reward(
      title: '₹50 Off Your Order',
      description: 'Valid on orders over ₹299',
      cost: 250,
      icon: Icons.sell_rounded,
    ),
    _Reward(
      title: 'Free Cold Brew',
      description: 'Any size, on the house',
      cost: 180,
      icon: Icons.local_cafe_rounded,
    ),
    _Reward(
      title: 'Free Delivery Week',
      description: 'Unlimited free delivery, 7 days',
      cost: 400,
      icon: Icons.delivery_dining_rounded,
    ),
  ];

  final List<Map<String, dynamic>> earnMethods = const [
    {'icon': Icons.shopping_bag_rounded, 'label': '1 pt / ₹10 spent'},
    {'icon': Icons.star_rounded, 'label': 'Rate an order · 5pt'},
    {'icon': Icons.group_add_rounded, 'label': 'Refer a friend · 50pt'},
    {'icon': Icons.cake_rounded, 'label': 'Birthday bonus · 100pt'},
  ];

  static const int _tierBronzeMax = 300;
  static const int _tierSilverMax = 700;

  String get _tierName {
    if (points >= _tierSilverMax) return 'Gold';
    if (points >= _tierBronzeMax) return 'Silver';
    return 'Bronze';
  }

  double get _tierProgress {
    if (points >= _tierSilverMax) return 1;
    if (points >= _tierBronzeMax) {
      return (points - _tierBronzeMax) / (_tierSilverMax - _tierBronzeMax);
    }
    return points / _tierBronzeMax;
  }

  String get _tierHint {
    if (points >= _tierSilverMax) return 'You\'ve reached the top tier 🎉';
    final target = points >= _tierBronzeMax ? _tierSilverMax : _tierBronzeMax;
    final remaining = target - points;
    final next = points >= _tierBronzeMax ? 'Gold' : 'Silver';
    return '$remaining pts to $next';
  }

  void _redeem(_Reward reward) {
    if (points < reward.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Need ${reward.cost - points} more points for this reward',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Redeem reward?', style: AppTextStyles.sectionTitle),
          content: Text(
            'Use ${reward.cost} points for "${reward.title}"?',
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
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() => points -= reward.cost);
                _showSuccess(reward);
              },
              child: Text('Redeem', style: AppTextStyles.button),
            ),
          ],
        );
      },
    );
  }

  void _showSuccess(_Reward reward) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Reward redeemed!', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 6),
                  Text(
                    reward.title,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text('Nice!', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _copyReferralCode() async {
    await Clipboard.setData(const ClipboardData(text: 'HARSH-BREW50'));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.pop(context),
                  icon:
                      const Icon(Icons.arrow_back, color: AppColors.darkBrown),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rewards', style: AppTextStyles.heading),
                      const SizedBox(height: 3),
                      Text(
                        'Earn points with every order',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildPointsCard(),
            const SizedBox(height: 22),
            Text('Ways to Earn', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            _buildEarnMethods(),
            const SizedBox(height: 22),
            Text('Redeem Points', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            ...List.generate(rewards.length, (index) {
              final reward = rewards[index];
              return FadeSlideIn(
                index: index,
                child: _buildRewardTile(reward),
              );
            }),
            const SizedBox(height: 10),
            _buildReferralCard(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // POINTS CARD
  // --------------------------------------------------

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _tierProgress),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return SizedBox(
                      width: 84,
                      height: 84,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 7,
                        backgroundColor: Colors.white.withOpacity(0.22),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_tierName Member',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedPopValue(
                  value: '$points pts',
                  style: AppTextStyles.heading.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _tierHint,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // EARN METHODS
  // --------------------------------------------------

  Widget _buildEarnMethods() {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: earnMethods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final method = earnMethods[index];
          return Container(
            width: 118,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  method['icon'] as IconData,
                  color: AppColors.primary,
                  size: 22,
                ),
                const Spacer(),
                Text(
                  method['label'] as String,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 9.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------
  // REWARD TILE
  // --------------------------------------------------

  Widget _buildRewardTile(_Reward reward) {
    final canRedeem = points >= reward.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(reward.icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.title, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 3),
                Text(reward.description, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _redeem(reward),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: canRedeem ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${reward.cost} pt',
                style: AppTextStyles.button.copyWith(
                  fontSize: 10.5,
                  color: canRedeem ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------
  // REFERRAL CARD
  // --------------------------------------------------

  Widget _buildReferralCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mediumBrown.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text('Invite & Earn 50 pts', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Share your code — you both get 50 points when they order.',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'HARSH-BREW50',
                    style: AppTextStyles.bodyMedium.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _copyReferralCode,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _copied ? Colors.green : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
