import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/model/address_model.dart';

abstract class AddressState {}

class AddressInitial  extends AddressState {}
class AddressLoading  extends AddressState {}

class AddressLoaded extends AddressState {
  final List<AddressModel> addresses;
  AddressLoaded(this.addresses);
}

class AddressActionLoading extends AddressState {
  final List<AddressModel> current;
  AddressActionLoading(this.current);
}

class AddressError extends AddressState {
  final String message;
  final List<AddressModel> previous;
  AddressError(this.message, [this.previous = const []]);
}

class AddressCubit extends Cubit<AddressState> {
  final ApiClient _api;
  AddressCubit(this._api) : super(AddressInitial());

  List<AddressModel> _list = [];

  List<AddressModel> get list => _list;

  AddressModel? get defaultAddress {
    if (_list.isEmpty) return null;
    try {
      return _list.firstWhere((a) => a.isDefault);
    } catch (_) {
      return _list.first;
    }
  }

  // ── GET customer/addresses ────────────────────────────────────────────────
  Future<void> fetchAddresses() async {
    emit(AddressLoading());
    try {
      final res = await _api.get('customer/addresses');
      _list = List.of(res['data']['items']??[])
          .map((e) => AddressModel.fromJson(e))
          .toList();
      emit(AddressLoaded(List.from(_list)));
    } on DioException catch (e) {
      emit(AddressError(handleDioError(e).message));
    } catch (ee) {      print("adddd $ee");

    emit(AddressError('Failed to load addresses'));
    }
  }

  // ── POST customer/addresses ───────────────────────────────────────────────
  Future<bool> addAddress(Map<String, dynamic> payload) async {
    emit(AddressActionLoading(List.from(_list)));
    try {
      await _api.post('customer/addresses', data: payload);
      await fetchAddresses();
      return true;
    } on DioException catch (e) {
      emit(AddressError(handleDioError(e).message, List.from(_list)));
      emit(AddressLoaded(List.from(_list))); // restore
      return false;
    } catch (_) {
      emit(AddressError('Failed to add address', List.from(_list)));
      emit(AddressLoaded(List.from(_list)));
      return false;
    }
  }

  // ── PUT customer/addresses/{id} ───────────────────────────────────────────
  Future<bool> updateAddress(int id, Map<String, dynamic> payload) async {
    emit(AddressActionLoading(List.from(_list)));
    try {
      await _api.put('customer/addresses/$id', data: payload);
      await fetchAddresses();
      return true;
    } on DioException catch (e) {
      emit(AddressError(handleDioError(e).message, List.from(_list)));
      emit(AddressLoaded(List.from(_list)));
      return false;
    } catch (_) {
      emit(AddressError('Failed to update address', List.from(_list)));
      emit(AddressLoaded(List.from(_list)));
      return false;
    }
  }

  // ── DELETE customer/addresses/{id} ────────────────────────────────────────
  Future<void> deleteAddress(int id) async {
    emit(AddressActionLoading(List.from(_list)));
    try {
      await _api.delete('customer/addresses/$id');
      await fetchAddresses();
    } on DioException catch (e) {
      emit(AddressError(handleDioError(e).message, List.from(_list)));
      emit(AddressLoaded(List.from(_list)));
    }
  }

  // ── POST customer/address/{id}/set-default ────────────────────────────────
  Future<void> setDefault(int id) async {
    emit(AddressActionLoading(List.from(_list)));
    try {
      await _api.post('customer/address/$id/set-default');
      await fetchAddresses();
    } on DioException catch (e) {
      emit(AddressError(handleDioError(e).message, List.from(_list)));
      emit(AddressLoaded(List.from(_list)));
    }
  }
}