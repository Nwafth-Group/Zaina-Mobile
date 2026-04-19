import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../model/banner_model.dart';
import '../model/service_model.dart';

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

      return HomeData(
        banners: (data['banners'] as List).map((e) => BannerModel.fromJson(e)).toList(),
        categories: (data['categories'] as List).map((e) => CategoryModel.fromJson(e)).toList(),
        popularServices: (data['popular_services'] as List).map((e) => ServiceModel.fromJson(e)).toList(),
      );
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}