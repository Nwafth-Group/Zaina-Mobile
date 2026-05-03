import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../data/model/booking_flow_model.dart';
import '../cubit/booking_flow_cubit.dart';
import '../widgets/step_date_time.dart';
import '../widgets/step_summary.dart';
import '../widgets/step_workers.dart';

class BookingFlowScreen extends StatefulWidget {
  final BookingFlowData initialData;

  const BookingFlowScreen({super.key, required this.initialData});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  final PageController _pageCtrl = PageController();
  int _step = 0;
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    context.read<BookingFlowCubit>().init(widget.initialData);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _step++);
    }
  }

  void _back() {
    if (_step > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut);
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingFlowCubit, BookingFlowState>(
      listener: (context, state) {
        if (state is BookingFlowSuccess) {
          _showSuccessDialog(context, state.bookingRef);
        }
        if (state is BookingFlowError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: ZienaColors.error,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: ZienaColors.white,
        appBar: AppBar(
          backgroundColor: ZienaColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: ZienaColors.textPrimary),
            onPressed: _back,
          ),
          title: BlocBuilder<BookingFlowCubit, BookingFlowState>(
            builder: (_, state) {
              final name = state is BookingFlowReady
                  ? state.flow.serviceName
                  : widget.initialData.serviceName;
              return Text(name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: ZienaColors.textPrimary,
                  ));
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: _buildStepIndicator(),
          ),
        ),
        body: PageView(
          controller: _pageCtrl,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StepDateTime(onNext: _next),
            StepWorkers(onNext: _next),
            const StepSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(_totalSteps, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 2 : 0),
            decoration: BoxDecoration(
              color: i <= _step
                  ? ZienaColors.primary
                  : ZienaColors.greyBorder,
            ),
          ),
        );
      }),
    );
  }

  void _showSuccessDialog(BuildContext context, String ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: ZienaColors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 110, height: 110,
              decoration: const BoxDecoration(
                  color: ZienaColors.bg2, shape: BoxShape.circle),
              child: Stack(alignment: Alignment.center, children: [
                const Icon(Icons.calendar_month_rounded,
                    size: 55, color: ZienaColors.primary),
                Positioned(
                  bottom: 10, right: 10,
                  child: Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      color: ZienaColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 16),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            Text('booking_confirmed'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: ZienaColors.textPrimary,
                )),
            const SizedBox(height: 8),
            if (ref.isNotEmpty)
              Text(ref,
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ZienaColors.primary,
                  )),
            const SizedBox(height: 8),
            Text('booking_confirmed_desc'.tr(),
                style: const TextStyle(
                  fontFamily: 'Poppins', fontSize: 13,
                  color: ZienaColors.textSecondary, height: 1.5,
                ),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // flow
                Navigator.pop(context); // detail
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ZienaColors.primary,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('done'.tr(),
                  style: const TextStyle(
                    fontFamily: 'Poppins', fontSize: 15,
                    fontWeight: FontWeight.w600, color: Colors.white,
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}