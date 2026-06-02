// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/theme/theme.dart';
// import '../../../../widgets/ziena_button.dart';
// import '../../data/model/booking_flow_model.dart';
// import '../cubit/booking_flow_cubit.dart';
//
// class StepDateTime extends StatefulWidget {
//   final VoidCallback onNext;
//   const StepDateTime({super.key, required this.onNext});
//
//   @override
//   State<StepDateTime> createState() => _StepDateTimeState();
// }
//
// class _StepDateTimeState extends State<StepDateTime> {
//   DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
//   ShiftModel? _selectedShift;
//   AvailableBlockModel? _selectedStartHour;
//   final List<int> _selectedWorkerIds = [];
//   final List<String> _selectedWorkerNames = [];
//
//   // ── Computed duration from selected start/end ─────────────────────────────
//   int? get _calculatedDuration {
//     if (_selectedStartHour == null) return null;
//     final start = int.parse(_selectedStartHour!.startTime.split(':')[0]);
//     final end   = int.parse(_selectedStartHour!.endTime.split(':')[0]);
//     final diff  = end - start;
//     return diff > 0 ? diff : null;
//   }
//
//   String get _apiDate =>
//       '${_selectedDate.year}-'
//           '${_selectedDate.month.toString().padLeft(2, '0')}-'
//           '${_selectedDate.day.toString().padLeft(2, '0')}';
//
//   String get _displayDate => DateFormat('dd MMM yyyy').format(_selectedDate);
//
//   @override
//   void initState() {
//     super.initState();
//     _loadShifts();
//   }
//
//   void _loadShifts() =>
//       context.read<BookingFlowCubit>().fetchShifts(_apiDate);
//
//   Future<void> _pickDate() async {
//     final d = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 14)),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: const ColorScheme.light(
//             primary: ZienaColors.primary,
//             onPrimary: Colors.white,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//     if (d != null) {
//       setState(() {
//         _selectedDate    = d;
//         _selectedShift   = null;
//         _selectedStartHour = null;
//       });
//       context.read<BookingFlowCubit>().fetchShifts(_apiDate);
//     }
//   }
//
//   /// Hours that can be selected as start (all available hours except the last)
//   List<AvailableBlockModel> get _startHours {
//     if (_selectedShift == null) return [];
//     final hours = _selectedShift!.availableBlocks;
//     // Start can be any hour except the very last (need at least 1h gap for end)
//     return hours;
//   }
//
//   bool get _canNext =>
//       _selectedShift != null &&
//           _selectedStartHour != null &&
//           _calculatedDuration != null &&
//           _calculatedDuration! > 0 &&
//           _selectedWorkerIds.isNotEmpty;
//
//   void _onNext() {
//     if (!_canNext) return;
//
//     final endTime =
//         '${_selectedStartHour!.endTime.split(':')[0].padLeft(2, '0')}:00';
//
//     final cubit = context.read<BookingFlowCubit>();
//     cubit.updateFlow(cubit.flow.copyWith(
//       selectedDate:          _apiDate,
//       selectedStartTime:     _selectedStartHour!.startTime,
//       selectedEndTime:       endTime,
//       selectedDurationHours: _calculatedDuration,
//       selectedWorkerIds: _selectedWorkerIds,
//       selectedShiftLabel:
//       _selectedShift!.dropdownLabel,
//     ));
//
//
//
//     widget.onNext(
//       _apiDate,
//       _selectedStartHour!.startTime,
//       endTime,
//       _calculatedDuration,
//       _selectedShift,
//       _selectedWorkerIds,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           // ── Date ───────────────────────────────────────────────────────────
//           _sectionTitle('select_date'.tr()),
//           const SizedBox(height: 10),
//           _DateTile(display: _displayDate, onTap: _pickDate),
//           const SizedBox(height: 20),
//
//           // ── Shift ───────────────────────────────────────────────────────────
//           _sectionTitle('select_time_slot'.tr()),
//           const SizedBox(height: 10),
//           BlocBuilder<BookingFlowCubit, BookingFlowState>(
//             builder: (context, state) {
//               if (state.shiftsLoading) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }
//
//               if (state.shifts.isEmpty) {
//                 return _EmptyBox(
//                   label: 'no_shifts_available'.tr(),
//                 );
//               }
//
//               return Column(
//                 children: state.shifts.map((shift) {
//                   return _ShiftTile(
//                     shift: shift,
//                     isSelected:
//                     _selectedShift?.id == shift.id,
//                     onTap: () {
//                       setState(() {
//                         _selectedShift = shift;
//                         _selectedStartHour = null;
//
//                         _selectedWorkerIds.clear();
//                         _selectedWorkerNames.clear();
//                       });
//                     },
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//
//           // ── Start hour ──────────────────────────────────────────────────────
//           if (_selectedShift != null) ...[
//             const SizedBox(height: 20),
//             _sectionTitle('select_period'.tr()),
//             const SizedBox(height: 10),
//             _startHours.isEmpty
//                 ? _EmptyBox(label: 'no_hours_available'.tr())
//                 : _HourGrid(
//               hours:        _startHours,
//               selectedHour: _selectedStartHour,
//               disabledHours: const [],
//               onSelect: (h) {
//                 setState(() {
//                   _selectedStartHour = h;
//                   _selectedWorkerIds.clear();
//                   _selectedWorkerNames.clear();
//                 });
//
//                 context.read<BookingFlowCubit>().fetchWorkers(
//                   date: _apiDate,
//                   startTime: h.startTime,
//                   durationHours: int.parse(
//                     h.endTime.split(':')[0],
//                   ) -
//                       int.parse(
//                         h.startTime.split(':')[0],
//                       ),
//                 );
//               },
//             ),
//           ],
//
//
//           // ── Duration summary (auto-calculated) ──────────────────────────────
//           if (_calculatedDuration != null) ...[
//             const SizedBox(height: 20),
//             _DurationSummary(
//               startHour: _selectedStartHour!.startTime,
//               endHour:   _selectedStartHour!.endTime,
//               duration:  _calculatedDuration!,
//             ),
//           ],
//
//           const SizedBox(height: 20),
//
//           if (_selectedStartHour != null) ...[
//             const SizedBox(height: 24),
//
//             _sectionTitle(
//               'select_worker'.tr(),
//             ),
//
//             const SizedBox(height: 10),
//
//             BlocBuilder<BookingFlowCubit, BookingFlowState>(
//               builder: (context, state) {
//
//                 final preferred =
//                     state.workers?.preferredWorkers ?? [];
//
//                 final others =
//                     state.workers?.otherWorkers ?? [];
//
//                 // Loading while keeping previous workers visible
//                 if (state.workersLoading &&
//                     preferred.isEmpty &&
//                     others.isEmpty) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: ZienaColors.primary,
//                     ),
//                   );
//                 }
//
//                 return Column(
//                   crossAxisAlignment:
//                   CrossAxisAlignment.start,
//                   children: [
//
//                     // Loading indicator on refresh
//                     if (state.workersLoading)
//                       const Padding(
//                         padding: EdgeInsets.only(
//                           bottom: 12,
//                         ),
//                         child: LinearProgressIndicator(
//                           color: ZienaColors.primary,
//                         ),
//                       ),
//
//                     // Preferred workers
//                     if (preferred.isNotEmpty) ...[
//                       Padding(
//                         padding: const EdgeInsets.only(
//                           bottom: 10,
//                         ),
//                         child: Text(
//                           'preferred_workers'.tr(),
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight:
//                             FontWeight.w700,
//                             color:
//                             ZienaColors.primary,
//                           ),
//                         ),
//                       ),
//
//                       ...preferred.map(
//                             (w) => _WorkerTile(
//                           worker: w,
//
//                           isSelected:
//                           _selectedWorkerIds
//                               .contains(w.id),
//
//                           onTap: () {
//                             setState(() {
//
//                               if (_selectedWorkerIds
//                                   .contains(
//                                 w.id,
//                               )) {
//
//                                 _selectedWorkerIds
//                                     .remove(
//                                   w.id,
//                                 );
//
//                                 _selectedWorkerNames
//                                     .remove(
//                                   w.name,
//                                 );
//
//                               } else {
//
//                                 // Multiple select
//                                 _selectedWorkerIds
//                                     .add(
//                                   w.id,
//                                 );
//
//                                 _selectedWorkerNames
//                                     .add(
//                                   w.name,
//                                 );
//                               }
//
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//
//                     // Other workers title
//                     if (others.isNotEmpty) ...[
//                       const SizedBox(height: 12),
//
//                       Padding(
//                         padding: const EdgeInsets.only(
//                           bottom: 10,
//                         ),
//                         child: Text(
//                           'other_workers'.tr(),
//                           style: const TextStyle(
//                             fontSize: 13,
//                             fontWeight:
//                             FontWeight.w700,
//                             color:
//                             ZienaColors
//                                 .textSecondary,
//                           ),
//                         ),
//                       ),
//
//                       ...others.map(
//                             (w) => _WorkerTile(
//                           worker: w,
//
//                           isSelected:
//                           _selectedWorkerIds
//                               .contains(w.id),
//
//                           onTap: () {
//                             setState(() {
//
//                               if (_selectedWorkerIds
//                                   .contains(
//                                 w.id,
//                               )) {
//
//                                 _selectedWorkerIds
//                                     .remove(
//                                   w.id,
//                                 );
//
//                                 _selectedWorkerNames
//                                     .remove(
//                                   w.name,
//                                 );
//
//                               } else {
//
//                                 _selectedWorkerIds
//                                     .add(
//                                   w.id,
//                                 );
//
//                                 _selectedWorkerNames
//                                     .add(
//                                   w.name,
//                                 );
//                               }
//
//                             });
//                           },
//                         ),
//                       ),
//                     ],
//
//                     // Empty state
//                     if (!state.workersLoading &&
//                         preferred.isEmpty &&
//                         others.isEmpty)
//
//                       _EmptyBox(
//                         label:
//                         'no_workers_available'
//                             .tr(),
//                       ),
//                   ],
//                 );
//               },
//             ),
//           ],
//
//           // ── Next ────────────────────────────────────────────────────────────
//           SizedBox(
//             width: double.infinity,
//             child: ZienaButton(
//               text: 'next'.tr(),
//               onTap: _canNext ? _onNext : null,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionTitle(String t) => Text(t,
//       style: const TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w700,
//         color: ZienaColors.textPrimary,
//       ));
// }
//
// // ── Date tile ─────────────────────────────────────────────────────────────────
// class _DateTile extends StatelessWidget {
//   final String display;
//   final VoidCallback onTap;
//   const _DateTile({required this.display, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding:
//         const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: ZienaColors.bg1,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: ZienaColors.greyBorder),
//         ),
//         child: Row(children: [
//           const Icon(Icons.calendar_today_rounded,
//               size: 18, color: ZienaColors.primary),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(display,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                   color: ZienaColors.textPrimary,
//                 )),
//           ),
//           const Icon(Icons.keyboard_arrow_down,
//               color: ZienaColors.textSecondary),
//         ]),
//       ),
//     );
//   }
// }
//
// // ── Shift tile ────────────────────────────────────────────────────────────────
// class _ShiftTile extends StatelessWidget {
//   final ShiftModel shift;
//   final bool isSelected;
//   final VoidCallback onTap;
//   const _ShiftTile({
//     required this.shift,
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
//         margin: const EdgeInsets.only(bottom: 10),
//         padding:
//         const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isSelected ? ZienaColors.bg2 : ZienaColors.bg1,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: isSelected
//                 ? ZienaColors.primary
//                 : ZienaColors.greyBorder,
//             width: isSelected ? 1.5 : 0.8,
//           ),
//         ),
//         child: Row(children: [
//           const Icon(Icons.wb_sunny_outlined,
//               color: ZienaColors.primary, size: 18),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(shift.dropdownLabel,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w500,
//                   color: isSelected
//                       ? ZienaColors.primary
//                       : ZienaColors.textPrimary,
//                 )),
//           ),
//           if (isSelected)
//             const Icon(Icons.check_circle,
//                 color: ZienaColors.primary, size: 18),
//         ]),
//       ),
//     );
//   }
// }
//
// // ── Hour grid — shared by start & end ────────────────────────────────────────
// class _HourGrid extends StatelessWidget {
//   final List<AvailableBlockModel> hours;
//   final AvailableBlockModel? selectedHour;
//   final List<String> disabledHours;
//   final ValueChanged<AvailableBlockModel> onSelect;
//
//   const _HourGrid({
//     required this.hours,
//     required this.selectedHour,
//     required this.disabledHours,
//     required this.onSelect,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 10,
//       runSpacing: 10,
//       children: hours.map((h) {
//         final sel      = selectedHour == h;
//         final disabled = disabledHours.contains(h);
//         return GestureDetector(
//           onTap: disabled ? null : () => onSelect(h),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             padding: EdgeInsets.all(5),
//             decoration: BoxDecoration(
//               color: sel
//                   ? ZienaColors.primary
//                   : disabled
//                   ? ZienaColors.greyLight
//                   : ZienaColors.bg1,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(
//                 color: sel
//                     ? ZienaColors.primary
//                     : ZienaColors.greyBorder,
//                 width: sel ? 1.5 : 0.8,
//               ),
//             ),
//             child: Text(h.label,
//                 style: TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                   color: sel
//                       ? Colors.white
//                       : disabled
//                       ? ZienaColors.textHint
//                       : ZienaColors.textPrimary,
//                 )),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }
//
// // ── Duration summary card ─────────────────────────────────────────────────────
// class _DurationSummary extends StatelessWidget {
//   final String startHour;
//   final String endHour;
//   final int duration;
//
//   const _DurationSummary({
//     required this.startHour,
//     required this.endHour,
//     required this.duration,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: ZienaColors.bg2,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//             color: ZienaColors.primary.withOpacity(0.3), width: 1),
//       ),
//       child: Row(children: [
//         Container(
//           width: 40, height: 40,
//           decoration: BoxDecoration(
//             color: ZienaColors.primary.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: const Icon(Icons.access_time_rounded,
//               color: ZienaColors.primary, size: 20),
//         ),
//         const SizedBox(width: 14),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('booking_duration'.tr(),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: ZienaColors.textSecondary,
//                   )),
//               const SizedBox(height: 2),
//               Text(
//                 '$startHour  →  $endHour',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                   color: ZienaColors.textPrimary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: ZienaColors.primary,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             '$duration ${'hrs'.tr()}',
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ]),
//     );
//   }
// }
//
// // ── Empty placeholder ─────────────────────────────────────────────────────────
// class _EmptyBox extends StatelessWidget {
//   final String label;
//   const _EmptyBox({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: ZienaColors.bg1,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: ZienaColors.greyBorder),
//       ),
//       child: Text(label,
//           style: const TextStyle(
//             fontSize: 13,
//             color: ZienaColors.textSecondary,
//           )),
//     );
//   }
// }
//
// // ── Workers counter ───────────────────────────────────────────────────────────
// class _CounterRow extends StatelessWidget {
//   final int value, min, max;
//   final VoidCallback onDecrement, onIncrement;
//
//   const _CounterRow({
//     required this.value,
//     required this.min,
//     required this.max,
//     required this.onDecrement,
//     required this.onIncrement,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding:
//       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: ZienaColors.bg1,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: ZienaColors.greyBorder, width: 0.8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             '$value ${'worker'.tr()}${value > 1 ? 's' : ''}',
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//               color: ZienaColors.textPrimary,
//             ),
//           ),
//           Row(children: [
//             _Btn(icon: Icons.remove,
//                 onTap: value > min ? onDecrement : null),
//             Padding(
//               padding:
//               const EdgeInsets.symmetric(horizontal: 16),
//               child: Text('$value',
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                     color: ZienaColors.textPrimary,
//                   )),
//             ),
//             _Btn(icon: Icons.add,
//                 onTap: value < max ? onIncrement : null),
//           ]),
//         ],
//       ),
//     );
//   }
// }
//
// class _Btn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   const _Btn({required this.icon, this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 34, height: 34,
//         decoration: BoxDecoration(
//           color: onTap != null ? ZienaColors.bg2 : ZienaColors.greyLight,
//           shape: BoxShape.circle,
//           border: Border.all(
//             color: onTap != null
//                 ? ZienaColors.primary.withOpacity(0.3)
//                 : ZienaColors.greyBorder,
//           ),
//         ),
//         child: Icon(icon,
//             size: 16,
//             color: onTap != null
//                 ? ZienaColors.primary
//                 : ZienaColors.textHint),
//       ),
//     );
//   }
// }
//
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