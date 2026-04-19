import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/failure.dart';
import '../../data/model/banner_model.dart';
import '../../data/repository/home_repository.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final HomeData data;
  HomeLoaded(this.data);
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repo;
  HomeCubit(this._repo) : super(HomeInitial());

  Future<void> fetchHomeData() async {
    emit(HomeLoading());
    try {
      final data = await _repo.getHomeData();
      emit(HomeLoaded(data));
    } on Failure catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError("An unexpected error occurred"));
    }
  }
}