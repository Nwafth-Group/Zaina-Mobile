import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../model/banner_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeData> getHomeData();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient _api;
  HomeRemoteDataSourceImpl(this._api);

@override
  Future<HomeData> getHomeData() async {
    try {
      final response = await _api.get('customer/home');
      final data = response['data'];
      
      // Parse upcoming appointment if present
      UpcomingAppointment? upcomingAppointment;
      if (data['upcoming_appointment'] != null && data['upcoming_appointment'].isNotEmpty) {
        upcomingAppointment = UpcomingAppointment.fromJson(data['upcoming_appointment']);
      }
      
      return HomeData(
        banners: List.of(data['banners'] ?? []).map((e) => BannerModel.fromJson(e)).toList(),
        upcomingAppointment: upcomingAppointment,
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}