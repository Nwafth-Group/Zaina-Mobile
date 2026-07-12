
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/services/data/model/review_customer_model.dart';
import 'package:zeina/features/services/data/model/service_detail_model.dart';
import '../../../../core/network/failure.dart';
import '../../data/repository/services_repository.dart';

class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  final ServicesRepository _repo;
  ServiceDetailCubit(this._repo) : super(ServiceDetailInitial());

  Future<void> fetch(int serviceId) async {
    emit(ServiceDetailLoading());
    try {
      final results = await Future.wait([
        _repo.fetchServiceDetail(serviceId),
        _repo.fetchReviews(serviceId),
      ]);
      emit(ServiceDetailLoaded(
        detail: results[0] as ServiceDetailModel,
        reviews: results[1] as List<ReviewModel>,
      ));
    } on DioException catch (e) {
      emit(ServiceDetailError(handleDioError(e).message));
    } catch (_) {
      emit(ServiceDetailError('Something went wrong'));
    }
  }
}

abstract class ServiceDetailState {}

class ServiceDetailInitial extends ServiceDetailState {}

class ServiceDetailLoading extends ServiceDetailState {}

class ServiceDetailLoaded extends ServiceDetailState {
  final ServiceDetailModel detail;
  final List<ReviewModel> reviews;
  ServiceDetailLoaded({required this.detail, required this.reviews});
}

class ServiceDetailError extends ServiceDetailState {
  final String message;
  ServiceDetailError(this.message);
}