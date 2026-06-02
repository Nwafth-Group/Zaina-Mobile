// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/theme/theme.dart';
// import '../../../../widgets/ziena_button.dart';
// import '../../data/model/booking_flow_model.dart';
// import '../cubit/booking_flow_cubit.dart';
//
// class StepWorkers extends StatefulWidget {
//   final VoidCallback onNext;
//   const StepWorkers({super.key, required this.onNext});
//
//   @override
//   State<StepWorkers> createState() => _StepWorkersState();
// }
//
// class _StepWorkersState extends State<StepWorkers> {
//   int? _selectedWorkerId;
//   String? _selectedWorkerName;
//
//   void _onNext() {
//     if (_selectedWorkerId == null) return;
//     final cubit = context.read<BookingFlowCubit>();
//     cubit.updateFlow(cubit.flow.copyWith(
//       selectedWorkerId: _selectedWorkerId,
//     ));
//     widget.onNext();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<BookingFlowCubit, BookingFlowState>(
//       builder: (context, state) {
//         if (state is BookingFlowWorkersLoading) {
//           return const Center(child: CircularProgressIndicator(
//               color: ZienaColors.primary, strokeWidth: 2));
//         }
//
//         List<WorkerModel> preferred = [];
//         List<WorkerModel> others = [];
//
//         if (state is BookingFlowWorkersLoaded) {
//           preferred = state.response.preferredWorkers;
//           others = state.response.otherWorkers;
//         }
//
//         return Stack(
//           children: [
//             SingleChildScrollView(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (preferred.isNotEmpty) ...[
//                     _sectionTitle('preferred_workers'.tr()),
//                     const SizedBox(height: 10),
//                     ...preferred.map((w) => _WorkerTile(
//                       worker: w,
//                       isSelected: _selectedWorkerId == w.id,
//                       onTap: () => setState(() {
//                         _selectedWorkerId = w.id;
//                         _selectedWorkerName = w.name;
//                       }),
//                     )),
//                     const SizedBox(height: 20),
//                   ],
//                   _sectionTitle(preferred.isEmpty
//                       ? 'available_workers'.tr()
//                       : 'other_workers'.tr()),
//                   const SizedBox(height: 10),
//                   if (others.isEmpty)
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: ZienaColors.bg1,
//                         borderRadius: BorderRadius.circular(14),
//                         border: Border.all(color: ZienaColors.greyBorder),
//                       ),
//                       child: Center(
//                         child: Text('no_workers_available'.tr(),
//                             style: const TextStyle(
//                               fontFamily: 'Poppins', fontSize: 13,
//                               color: ZienaColors.textSecondary,
//                             )),
//                       ),
//                     )
//                   else
//                     ...others.map((w) => _WorkerTile(
//                       worker: w,
//                       isSelected: _selectedWorkerId == w.id,
//                       onTap: () => setState(() {
//                         _selectedWorkerId = w.id;
//                         _selectedWorkerName = w.name;
//                       }),
//                     )),
//                 ],
//               ),
//             ),
//
//             // ── Next button ─────────────────────────────────────────────────
//             Positioned(
//               bottom: 0, left: 0, right: 0,
//               child: Container(
//                 padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
//                 color: ZienaColors.white,
//                 child: ZienaButton(
//                   text: 'next'.tr(),
//                   onTap: _selectedWorkerId != null ? _onNext : null,
//                   disabledBackgroundColor:
//                       ZienaColors.primary.withOpacity(0.4),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _sectionTitle(String t) => Text(t,
//       style: const TextStyle(
//         fontFamily: 'Poppins', fontSize: 14,
//         fontWeight: FontWeight.w700, color: ZienaColors.textPrimary,
//       ));
// }
//
// class _WorkerTile extends StatelessWidget {
//   final WorkerModel worker;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _WorkerTile({
//     required this.worker,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: isSelected ? ZienaColors.bg2 : ZienaColors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected ? ZienaColors.primary : ZienaColors.greyBorder,
//             width: isSelected ? 1.5 : 0.8,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 6, offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(children: [
//           // Avatar
//           Container(
//             width: 50, height: 50,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle, color: ZienaColors.bg3,
//               border: Border.all(
//                   color: ZienaColors.primary.withOpacity(0.2), width: 1.5),
//             ),
//             child: worker.avatar != null
//                 ? ClipOval(child: Image.network(worker.avatar!, fit: BoxFit.cover))
//                 : Center(child: Text(
//                 worker.name.isNotEmpty ? worker.name[0].toUpperCase() : '?',
//                 style: const TextStyle(
//                   fontFamily: 'Poppins', fontSize: 20,
//                   fontWeight: FontWeight.w700, color: ZienaColors.primary,
//                 ))),
//           ),
//           const SizedBox(width: 14),
//
//           // Info
//           Expanded(child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(worker.name,
//                   style: const TextStyle(
//                     fontFamily: 'Poppins', fontSize: 14,
//                     fontWeight: FontWeight.w600, color: ZienaColors.textPrimary,
//                   )),
//               const SizedBox(height: 2),
//               if (worker.nationality != null)
//                 Row(children: [
//                   const Icon(Icons.flag_outlined,
//                       size: 12, color: ZienaColors.textSecondary),
//                   const SizedBox(width: 4),
//                   Text(worker.nationality!,
//                       style: const TextStyle(
//                         fontFamily: 'Poppins', fontSize: 11,
//                         color: ZienaColors.textSecondary,
//                       )),
//                 ]),
//               if (worker.rating != null) ...[
//                 const SizedBox(height: 2),
//                 Row(children: [
//                   const Icon(Icons.star_rounded,
//                       color: Color(0xFFFFB800), size: 13),
//                   const SizedBox(width: 3),
//                   Text(worker.rating!.toStringAsFixed(1),
//                       style: const TextStyle(
//                         fontFamily: 'Poppins', fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFFFFB800),
//                       )),
//                 ]),
//               ],
//             ],
//           )),
//
//           // Radio
//           Container(
//             width: 22, height: 22,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isSelected ? ZienaColors.primary : Colors.transparent,
//               border: Border.all(
//                   color: isSelected ? ZienaColors.primary : ZienaColors.greyBorder,
//                   width: 2),
//             ),
//             child: isSelected
//                 ? const Icon(Icons.check, color: Colors.white, size: 14)
//                 : null,
//           ),
//         ]),
//       ),
//     );
//   }
// }