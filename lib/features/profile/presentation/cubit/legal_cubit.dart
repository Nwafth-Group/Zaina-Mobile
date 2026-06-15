import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../../data/models/legal_model.dart';

// ── State ──────────────────────────────────────────────────────────────────────

abstract class LegalState {}

class LegalInitial extends LegalState {}

class LegalLoading extends LegalState {}

class LegalLoaded extends LegalState {
  final List<LegalSection> sections;
  LegalLoaded(this.sections);
}

class LegalError extends LegalState {
  final String message;
  LegalError(this.message);
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

class LegalCubit extends Cubit<LegalState> {
  final ApiClient _api;
  final String endpoint;

  LegalCubit(this._api, {required this.endpoint}) : super(LegalInitial());

  Future<void> fetch() async {
    emit(LegalLoading());
    try {
      final res = await _api.get(endpoint);
      final items = (res['data']['items'] as List)
          .map((e) => LegalSection.fromJson(e))
          .toList();
      emit(LegalLoaded(items));
    } on DioException catch (e) {
      emit(LegalError(handleDioError(e).message));
    } catch (e) {
      emit(LegalError(e.toString()));
    }
  }

  void toggle(int index) {
    final current = state;
    if (current is! LegalLoaded) return;
    final updated = List<LegalSection>.from(current.sections);
    updated[index] = LegalSection(
      id: updated[index].id,
      title: updated[index].title,
      content: updated[index].content,
      isExpanded: !updated[index].isExpanded,
    );
    emit(LegalLoaded(updated));
  }
}
