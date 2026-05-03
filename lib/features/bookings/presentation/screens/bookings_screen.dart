import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../data/model/booking_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../cubit/bookings_cubit.dart';
import '../widgets/bokking_card.dart';
import 'booking_details_screen.dart';

class BookingsScreen extends StatefulWidget {
  final bool isLoggedIn;
  const BookingsScreen({super.key, required this.isLoggedIn});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final ScrollController _scroll = ScrollController();
  BookingStatusEnum _filter = BookingStatusEnum.all;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      context.read<BookingsCubit>().fetchBookings(refresh: true);
    }
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        context.read<BookingsCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onFilterChange(BookingStatusEnum f) {
    setState(() => _filter = f);
    context.read<BookingsCubit>().fetchBookings(filter: f, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              'my_bookings'.tr(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            Expanded(
              child: widget.isLoggedIn ? _buildList() : _buildSignInGate(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        children: BookingStatusEnum.values.map((s) {
          final isSelected = _filter == s;
          return GestureDetector(
            onTap: () => _onFilterChange(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? ZienaColors.primary : ZienaColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? ZienaColors.primary : ZienaColors.bg4,
                ),
              ),
              child: Text(
                s.label,
                style: TextStyle(
                  
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : ZienaColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    return BlocBuilder<BookingsCubit, BookingsState>(
      builder: (context, state) {
        if (state is BookingsLoading) {
          return const Center(
            child: CircularProgressIndicator(
                color: ZienaColors.primary, strokeWidth: 2),
          );
        }
        if (state is BookingsError) {
          return _buildError(context, state.message);
        }

        final bookings = state is BookingsLoaded
            ? state.bookings
            : state is BookingsLoadingMore
            ? state.current
            : <BookingModel>[];
        final isMore = state is BookingsLoadingMore;

        if (bookings.isEmpty && state is BookingsLoaded) {
          return _buildEmpty();
        }

        return RefreshIndicator(
          onRefresh: () => context
              .read<BookingsCubit>()
              .fetchBookings(filter: _filter, refresh: true),
          color: ZienaColors.primary,
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            physics: const BouncingScrollPhysics(),
            itemCount: bookings.length + (isMore ? 1 : 0),
            itemBuilder: (_, i) {
              if (i == bookings.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: ZienaColors.primary, strokeWidth: 2),
                  ),
                );
              }
              final b = bookings[i];
              return BookingCard(
                booking: b,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<BookingDetailCubit>()
                        ..fetchDetail(b.id),
                      child: BookingDetailScreen(bookingId: b.id),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90, height: 90,
          decoration: const BoxDecoration(
              color: ZienaColors.bg2, shape: BoxShape.circle),
          child: const Icon(Icons.calendar_month_outlined,
              color: ZienaColors.primary, size: 40),
        ),
        const SizedBox(height: 16),
        Text('no_bookings'.tr(),
            style: const TextStyle(
              
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            )),
      ],
    ),
  );

  Widget _buildError(BuildContext context, String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.wifi_off_rounded,
            size: 60, color: ZienaColors.textHint),
        const SizedBox(height: 12),
        Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: ZienaColors.textSecondary)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => context
              .read<BookingsCubit>()
              .fetchBookings(filter: _filter, refresh: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: ZienaColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text('retry'.tr(),
              style: const TextStyle(
                   color: Colors.white)),
        ),
      ],
    ),
  );

  Widget _buildSignInGate() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110, height: 110,
            decoration: const BoxDecoration(
                color: ZienaColors.bg2, shape: BoxShape.circle),
            child: const Icon(Icons.calendar_month_rounded,
                size: 50, color: ZienaColors.primary),
          ),
          const SizedBox(height: 28),
          Text('signin_required_title'.tr(),
              style: const TextStyle( fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text('signin_required_desc_bookings'.tr(),
              style: const TextStyle( fontSize: 14,
                color: ZienaColors.textSecondary, height: 1.6,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: 36),
          ElevatedButton(
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
                   fontSize: 16,
                  fontWeight: FontWeight.w600, color: Colors.white,
                )),
          ),
        ],
      ),
    ),
  );
}