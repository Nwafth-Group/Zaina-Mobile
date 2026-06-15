import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../../wallet/data/models/wallet_model.dart';

class CardsCubit extends Cubit<CardsState> {
  final ApiClient _api;
  CardsCubit(this._api) : super(CardsInitial());

  List<CardModel> _cards = [];
  List<CardModel> get cards => _cards;

  // ── GET customer/cards ────────────────────────────────────────────────────
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
      emit(CardsError('Failed to load cards'));
    }
  }

  // ── POST customer/cards ───────────────────────────────────────────────────
  Future<bool> addCard({
    required String cardToken,
    required String lastFour,
    required String brand,
    required String cardHolderName,
    bool isDefault = false,
  }) async {
    emit(CardActionLoading(List.from(_cards)));
    try {
      await _api.post('customer/cards', data: {
        'card_token':      cardToken,
        'last_four':       lastFour,
        'card_brand':      brand,
        'card_holder_name': cardHolderName,
        if (isDefault) 'is_default': true,
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

  // ── DELETE customer/cards/{id} ─────────────────────────────────────────────
  Future<void> deleteCard(int id) async {
    emit(CardActionLoading(List.from(_cards)));
    try {
      await _api.delete('customer/cards/$id');
      _cards.removeWhere((c) => c.id == id);
      emit(CardsLoaded(List.from(_cards)));
    } on DioException catch (e) {
      emit(CardsError(handleDioError(e).message));
      emit(CardsLoaded(List.from(_cards)));
    }
  }
}

abstract class CardsState {}

class CardsInitial      extends CardsState {}
class CardsLoading      extends CardsState {}

class CardsLoaded extends CardsState {
  final List<CardModel> cards;
  CardsLoaded(this.cards);
}

class CardActionLoading extends CardsState {
  final List<CardModel> current;
  CardActionLoading(this.current);
}

class CardAdded   extends CardsState {}
class CardDeleted extends CardsState {}

class CardsError extends CardsState {
  final String message;
  CardsError(this.message);
}