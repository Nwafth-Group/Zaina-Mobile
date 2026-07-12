import 'package:zeina/features/services/data/model/service_feature_model.dart';

import '../../data/model/visit_type_model.dart';

class BookingSelectionData {
  final int serviceId;
  final VisitTypeModel visitType;
  final List<DateTime> selectedDates;
  final ServiceShiftModel shift;
  final int workerCount;

  /// IDs of specifically chosen preferred workers. Empty when the user
  /// didn't pick any (either no preferred workers existed for this service,
  /// or they left it to random assignment) — the backend assigns randomly
  /// in that case.
  final List<int> preferredWorkerIds;

  BookingSelectionData({
    required this.serviceId,
    required this.visitType,
    required this.selectedDates,
    required this.shift,
    required this.workerCount,
    required this.preferredWorkerIds,
  });
}