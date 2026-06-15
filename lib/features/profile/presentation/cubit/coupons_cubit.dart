import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/models/coupon_model.dart';

abstract class CouponsState {}
class CouponsInitial extends CouponsState {}
class CouponsLoading extends CouponsState {}
class CouponsLoaded  extends CouponsState {
  final List<CouponModel> coupons;
  CouponsLoaded(this.coupons);
}
class CouponsError extends CouponsState {
  final String message;
  CouponsError(this.message);
}
class CouponsCubit extends Cubit<CouponsState> {
  final ApiClient _api;
  CouponsCubit(this._api) : super(CouponsInitial());

  Future<void> fetchCoupons() async {
    emit(CouponsLoading());
    try {
      final res = await _api.get('customer/coupons');
      final items = (res['data']['items'] as List<dynamic>? ?? [])
          .map((e) => CouponModel.fromJson(e))
          .toList();
      emit(CouponsLoaded(items));
    } on DioException catch (e) {
      emit(CouponsError(handleDioError(e).message));
    } catch (_) {
      emit(CouponsError('Failed to load coupons'));
    }
  }

  Future<CouponModel?> fetchCouponDetail(int id) async {
    try {
      final res = await _api.get('customer/coupons/$id');
      return CouponModel.fromJson(res['data']);
    } catch (_) {
      return null;
    }
  }
}