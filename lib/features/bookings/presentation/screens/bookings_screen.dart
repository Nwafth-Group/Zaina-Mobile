import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/model/booking_model.dart';
class BookingsScreen extends StatefulWidget {
  final bool isLoggedIn;
  const BookingsScreen({super.key, required this.isLoggedIn});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  BookingStatus _selectedStatus = BookingStatus.all;

  List<BookingModel> get _filtered {
    if (_selectedStatus == BookingStatus.all) {
      return BookingModel.mockList;
    }
    return BookingModel.mockList
        .where((b) => b.status == _selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      body: SafeArea(
        child: Column(
          children: [
            // ── Title ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Text(
                'bookings'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                ),
              ),
            ),

            // ── Status filter tabs ──────────────────────────────────────────
            _buildFilterTabs(),
            const SizedBox(height: 16),

            // ── List ───────────────────────────────────────────────────────
            Expanded(
              child: widget.isLoggedIn
                  ? _buildList()
                  : _buildSignInRequired(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final statuses = BookingStatus.values;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = statuses[i];
          final isSelected = _selectedStatus == s;
          return GestureDetector(
            onTap: () => setState(() => _selectedStatus = s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? ZienaColors.primary : ZienaColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? ZienaColors.primary
                      : ZienaColors.bg4.withOpacity(0.6),
                ),
              ),
              child: Text(
                s.label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : ZienaColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: ZienaColors.bg2,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_outlined,
                  color: ZienaColors.primary, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'no_bookings'.tr(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ZienaColors.textPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) => BookingCard(
        booking: items[i],
        onTap: () {
          
        }
      ),
    );
  }

  Widget _buildSignInRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: ZienaColors.bg2,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_month_rounded,
                  size: 50, color: ZienaColors.primary),
            ),
            const SizedBox(height: 28),
            Text('signin_required_title'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('signin_required_desc_bookings'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: ZienaColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: ZienaColors.primary,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('log_in'.tr(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// BOOKING CARD — used in list
// ═══════════════════════════════════════════════════════
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ZienaColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ZienaColors.greyBorder, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Service image ─────────────────────────────────────────────
            ClipRRect(
              borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(18)),
              child: booking.serviceImage != null
                  ? Image.network(
                booking.serviceImage!,
                width: 110,
                height: 108,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 110,
                height: 108,
                color: ZienaColors.bg3,
                child: const Icon(
                    Icons.cleaning_services_rounded,
                    color: ZienaColors.primary,
                    size: 40),
              ),
            ),

            // ── Details ───────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      booking.serviceName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Price
                    Text(
                      '${booking.price.toStringAsFixed(0)} ${booking.currency}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: ZienaColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Info chips row
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.bookmark_outline_rounded,
                          label: booking.status.label,
                          color: _statusColor(booking.status),
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: booking.location,
                          color: ZienaColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.access_time_rounded,
                          label: '${booking.durationHours} Hours',
                          color: ZienaColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Date panel ────────────────────────────────────────────────
            Container(
              width: 64,
              height: 108,
              decoration: const BoxDecoration(
                color: ZienaColors.primary,
                borderRadius:
                BorderRadius.horizontal(right: Radius.circular(18)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${booking.day}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    booking.month,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return const Color(0xFF2196F3);
      case BookingStatus.inService:
        return const Color(0xFFFF9800);
      case BookingStatus.completed:
        return const Color(0xFF4CAF50);
      case BookingStatus.cancelled:
        return const Color(0xFFE53935);
      default:
        return ZienaColors.textSecondary;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}