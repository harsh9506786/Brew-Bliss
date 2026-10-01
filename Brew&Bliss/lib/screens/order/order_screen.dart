import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/skeleton.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

enum _OrderStatus { preparing, onTheWay, delivered }

class _Order {
  final String id;
  final String date;
  final String eta;
  final double total;
  final List<String> itemNames;
  final String thumbnail;
  _OrderStatus status;
  int rating;

  _Order({
    required this.id,
    required this.date,
    required this.eta,
    required this.total,
    required this.itemNames,
    required this.thumbnail,
    required this.status,
    this.rating = 0,
  });
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _expanded = {};
  bool _refreshing = false;

  // Skeleton cards while the orders load for the first time.
  bool _isLoading = true;

  final List<_Order> ongoing = [
    _Order(
      id: '#BB-2481',
      date: 'Today, 2:14 PM',
      eta: '12 min',
      total: 528,
      itemNames: ['Cappuccino', 'Caffe Latte'],
      thumbnail:
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?auto=format&fit=crop&w=300&q=80',
      status: _OrderStatus.onTheWay,
    ),
    _Order(
      id: '#BB-2477',
      date: 'Today, 11:02 AM',
      eta: '25 min',
      total: 269,
      itemNames: ['Cold Brew'],
      thumbnail:
          'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=300&q=80',
      status: _OrderStatus.preparing,
    ),
  ];

  final List<_Order> past = [
    _Order(
      id: '#BB-2402',
      date: 'Sep 21, 5:40 PM',
      eta: '',
      total: 568,
      itemNames: ['Caffe Latte', 'Vanilla Latte'],
      thumbnail:
          'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=300&q=80',
      status: _OrderStatus.delivered,
      rating: 5,
    ),
    _Order(
      id: '#BB-2388',
      date: 'Sep 18, 9:15 AM',
      eta: '',
      total: 199,
      itemNames: ['Americano'],
      thumbnail:
          'https://images.unsplash.com/photo-1497515114629-f71d768fd07c?auto=format&fit=crop&w=300&q=80',
      status: _OrderStatus.delivered,
    ),
    _Order(
      id: '#BB-2350',
      date: 'Sep 12, 4:22 PM',
      eta: '',
      total: 299,
      itemNames: ['Mocha'],
      thumbnail:
          'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?auto=format&fit=crop&w=300&q=80',
      status: _OrderStatus.delivered,
      rating: 4,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            _buildTabBar(),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _isLoading
                    ? const [ListItemSkeleton(), ListItemSkeleton()]
                    : [
                        _buildOngoingList(),
                        _buildPastList(),
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
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Orders', style: AppTextStyles.heading),
              const SizedBox(height: 3),
              Text(
                _isLoading
                    ? 'Loading your orders...'
                    : '${ongoing.length} ongoing  •  ${past.length} completed',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(11),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.darkBrown,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
          unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12.5,
          ),
          tabs: const [
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // ONGOING
  // --------------------------------------------------

  Widget _buildOngoingList() {
    if (ongoing.isEmpty) {
      return _emptyState(
        icon: Icons.local_cafe_outlined,
        title: 'No ongoing orders',
        subtitle: 'Your active orders will show up here',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _handleRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
        itemCount: ongoing.length,
        itemBuilder: (context, index) {
          final order = ongoing[index];
          final expanded = _expanded.contains(order.id);

          return FadeSlideIn(
            index: index,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        if (expanded) {
                          _expanded.remove(order.id);
                        } else {
                          _expanded.add(order.id);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: AppNetworkImage(
                              url: order.thumbnail,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.itemNames.join(', '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${order.id}  •  ₹${order.total.toStringAsFixed(0)}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _statusChip(order.status),
                              const SizedBox(height: 6),
                              AnimatedRotation(
                                duration: const Duration(milliseconds: 220),
                                turns: expanded ? 0.5 : 0,
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.mediumBrown,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOut,
                    child: expanded
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                            child: _trackingStepper(order),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(_OrderStatus status) {
    late String label;
    late Color color;

    switch (status) {
      case _OrderStatus.preparing:
        label = 'Preparing';
        color = AppColors.mediumBrown;
        break;
      case _OrderStatus.onTheWay:
        label = 'On the way';
        color = AppColors.primary;
        break;
      case _OrderStatus.delivered:
        label = 'Delivered';
        color = Colors.green.shade600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 9.5,
        ),
      ),
    );
  }

  Widget _trackingStepper(_Order order) {
    final steps = ['Placed', 'Preparing', 'On the way', 'Delivered'];
    int activeStep;
    switch (order.status) {
      case _OrderStatus.preparing:
        activeStep = 1;
        break;
      case _OrderStatus.onTheWay:
        activeStep = 2;
        break;
      case _OrderStatus.delivered:
        activeStep = 3;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 16),
        Row(
          children: List.generate(steps.length, (i) {
            final reached = i <= activeStep;
            final isCurrent = i == activeStep;

            return Expanded(
              child: Row(
                children: [
                  isCurrent
                      ? _PulsingDot(color: AppColors.primary)
                      : Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                reached ? AppColors.primary : AppColors.border,
                          ),
                        ),
                  if (i != steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i < activeStep
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(steps.length, (i) {
            final reached = i <= activeStep;
            return Expanded(
              child: Text(
                steps[i],
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 8.5,
                  color:
                      reached ? AppColors.darkBrown : AppColors.textSecondary,
                  fontWeight: reached ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Arriving in ${order.eta}',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 11.5),
              ),
              const Spacer(),
              Text(
                order.date,
                style: AppTextStyles.bodySmall.copyWith(fontSize: 9.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // PAST
  // --------------------------------------------------

  Widget _buildPastList() {
    if (past.isEmpty) {
      return _emptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No past orders yet',
        subtitle: 'Completed orders will appear here',
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _handleRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
        itemCount: past.length,
        itemBuilder: (context, index) {
          final order = past[index];

          return FadeSlideIn(
            index: index,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: AppNetworkImage(
                          url: order.thumbnail,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.itemNames.join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${order.date}  •  ₹${order.total.toStringAsFixed(0)}',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (i) {
                          final filled = i < order.rating;
                          return GestureDetector(
                            onTap: () {
                              setState(() => order.rating = i + 1);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Icon(
                                filled ? Icons.star : Icons.star_border,
                                size: 18,
                                color: const Color(0xFFD18B22),
                              ),
                            ),
                          );
                        }),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${order.itemNames.first} added to cart again',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(
                          'Reorder',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: AppColors.mediumBrown),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// PULSING DOT (current step indicator)
// --------------------------------------------------

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 1 + (_controller.value * 0.6);
        return SizedBox(
          width: 20,
          height: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color
                        .withOpacity(0.35 * (1 - _controller.value)),
                  ),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
