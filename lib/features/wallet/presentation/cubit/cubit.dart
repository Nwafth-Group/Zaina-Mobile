
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

// cards
abstract class CardsState {}
class CardsInitial      extends CardsState {}
class CardsLoading      extends CardsState {}
class CardsLoaded       extends CardsState {
  final List<CardModel> cards;
  CardsLoaded(this.cards);
}
class CardActionLoading extends CardsState {
  final List<CardModel> current;
  CardActionLoading(this.current);
}
class CardAdded         extends CardsState {}
class CardDeleted       extends CardsState {}
class CardsError        extends CardsState {
  final String message;
  CardsError(this.message);
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

// ── Cards Cubit ───────────────────────────────────────────────────────────────
class CardsCubit extends Cubit<CardsState> {
  final ApiClient _api;
  CardsCubit(this._api) : super(CardsInitial());

  List<CardModel> _cards = [];
  List<CardModel> get cards => _cards;

  Future<void> fetchCards() async {
    emit(CardsLoading());
    try {
      final res = await _api.get('customer/cards');
      _cards = (res['data']['items'] as List<dynamic>? ?? [])
          .map((e) => CardModel.fromJson(e))
          .toList();
      emit(CardsLoaded(List.from(_cards)));
    } on DioException catch (e) {
      emit(CardsError(handleDioError(e).message));
    } catch (_) {
      emit(CardsError('Something went wrong'));
    }
  }

  Future<bool> addCard({
    required String cardToken,
    required String lastFour,
    required String brand,
    required String cardHolderName,
  }) async {
    emit(CardActionLoading(List.from(_cards)));
    try {
      await _api.post('customer/cards', data: {
        'card_token':      cardToken,
        'last_four':       lastFour,
        'card_brand':      brand,
        'card_holder_name': cardHolderName,
      });
      await fetchCards();
      emit(CardAdded());
      return true;
    } on DioException catch (e) {
      emit(CardsError(handleDioError(e).message));
      emit(CardsLoaded(List.from(_cards)));
      return false;
    } catch (_) {
      emit(CardsError('Failed to add card'));
      emit(CardsLoaded(List.from(_cards)));
      return false;
    }
  }

  Future<void> deleteCard(int cardId) async {
    emit(CardActionLoading(List.from(_cards)));
    try {
      await _api.delete('customer/cards/$cardId');
      _cards.removeWhere((c) => c.id == cardId);
      emit(CardsLoaded(List.from(_cards)));
    } on DioException catch (e) {
      emit(CardsError(handleDioError(e).message));
      emit(CardsLoaded(List.from(_cards)));
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