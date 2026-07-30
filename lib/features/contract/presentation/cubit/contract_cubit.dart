import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/services/data/model/visit_type_model.dart';
import '../../../../core/network/api_client.dart';

abstract class ContractState {}
class ContractInitial extends ContractState {}
class ContractLoading extends ContractState {}
class ContractLoaded extends ContractState {
  final Uint8List pdfBytes;
  ContractLoaded(this.pdfBytes);
}
class ContractError extends ContractState {
  final String message;
  ContractError(this.message);
}

class ContractCubit extends Cubit<ContractState> {
  final ApiClient _api;
  ContractCubit(this._api) : super(ContractInitial());

  Future<void> fetchContractPreview({
    required int serviceId,
    required int addressId,
    // Omit for configurable-hourly services (Hospitality Worker,
    // Babysitter) — matches the `visitType` handling already used in
    // CheckoutScreen._handlePay.
    VisitTypeEnum? visitType,
    required List<String> dates, // 'yyyy-MM-dd'
    required String startTime,
    int? duration,
    String? workerGender,
    required List<int> workerIds,
    int? numberOfChildren,
    List<int>? childAgeGroups,
    int? numberOfPersons,
    String? note,
    required String paymentMethod,
    String? couponCode,
  }) async
  {
    emit(ContractLoading());
    try {
      // Uses postBytes, not post/postRaw — this endpoint returns the
      // contract as an actual PDF file (binary, starts with "%PDF-1.4"),
      // not HTML and not the usual {status, message, data} JSON envelope.
      final bytes = await _api.postBytes(
        'customer/bookings/contract-preview',
        data: {
          'service_id': serviceId,
          'address_id': addressId,
          if (visitType != null) 'visit_type': visitType.validateApiValue,
          'dates': dates,
          'start_time': startTime,
          if (duration != null) 'duration': duration,
          if (workerGender != null) 'worker_gender': workerGender,
          'worker_ids': workerIds,
          if (numberOfChildren != null) 'number_of_children': numberOfChildren,
          if (childAgeGroups != null) 'child_age_groups': childAgeGroups,
          if (numberOfPersons != null) 'number_of_persons': numberOfPersons,
          if (note != null) 'note': note,
          'payment_method': paymentMethod,
          'coupon_code': couponCode ?? '',
        },
      );

      if (bytes.isEmpty) {
        emit(ContractError('Failed to load contract'));
        return;
      }
      emit(ContractLoaded(bytes));
    } catch (e) {
      // ApiClient's post/postBytes don't actually throw the DioException —
      // they catch it internally and `throw` the computed error message
      // String instead, so `e` here is typically a String already, not an
      // exception object.
      emit(ContractError(e is String ? e : 'Failed to load contract'));
    }
  }

  /// Fetches the contract PDF for an existing booking — used from the
  /// booking detail screen's "Documents" section, as opposed to
  /// [fetchContractPreview] which previews a contract for a booking that
  /// hasn't been created yet (checkout screen).
  Future<void> fetchBookingContract(int bookingId) async {
    emit(ContractLoading());
    try {
      final bytes = await _api.getBytes('customer/bookings/$bookingId/contract');

      if (bytes.isEmpty) {
        emit(ContractError('Failed to load contract'));
        return;
      }
      emit(ContractLoaded(bytes));
    } catch (e) {
      emit(ContractError(e is String ? e : 'Failed to load contract'));
    }
  }
}