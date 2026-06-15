
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/models/wallet_model.dart';


abstract class WalletState {}
class WalletInitial  extends WalletState {}
class WalletLoading  extends WalletState {}
class WalletLoaded   extends WalletState {
  final WalletData data;
  WalletLoaded(this.data);
}
class WalletError extends WalletState {
  final String message;
  WalletError(this.message);
}

// top-up
abstract class TopUpState {}
class TopUpInitial  extends TopUpState {}
class TopUpLoading  extends TopUpState {}
class TopUpSuccess  extends TopUpState {}
class TopUpError    extends TopUpState {
  final String message;
  TopUpError(this.message);
}

// ── Wallet Cubit ──────────────────────────────────────────────────────────────
class WalletCubit extends Cubit<WalletState> {
  final ApiClient _api;
  WalletCubit(this._api) : super(WalletInitial());

  WalletData? _data;
  WalletData? get data => _data;

  Future<void> fetchWallet({
    WalletFilter filter = WalletFilter.all,
    String? fromDate,
    String? toDate,
  }) async {
    emit(WalletLoading());
    try {
      final params = <String, dynamic>{};
      if (filter != WalletFilter.all) {
        params['filter'] = filter.apiValue;
      }
      if (fromDate != null) params['from_date'] = fromDate;
      if (toDate != null)   params['to_date']   = toDate;

      final res = await _api.get('customer/wallet', queryParameters: params);
      _data = WalletData.fromJson(res);
      emit(WalletLoaded(_data!));
    } on DioException catch (e) {
      emit(WalletError(handleDioError(e).message));
    } catch (ee) {
      print("sssss $ee");
      emit(WalletError('Something went wrong'));
    }
  }
}



// ── Top-up Cubit ──────────────────────────────────────────────────────────────
class TopUpCubit extends Cubit<TopUpState> {
  final ApiClient _api;
  TopUpCubit(this._api) : super(TopUpInitial());

  Future<void> topUp({
    required double amount,
    required String paymentMethod, // 'card' etc.
    int? cardId,
  }) async {
    emit(TopUpLoading());
    try {
      await _api.post('customer/wallet/top-up', data: {
        'amount':         amount,
        'payment_method': paymentMethod,
        'card_id': ?cardId,
      });
      emit(TopUpSuccess());
    } on DioException catch (e) {
      emit(TopUpError(handleDioError(e).message));
    } catch (_) {
      emit(TopUpError('Top-up failed'));
    }
  }
}