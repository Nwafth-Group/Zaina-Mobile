import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../model/banner_model.dart';

abstract class CategoriesRemoteDataSource {
  Future<PaginatedCategories> getCategories({int page = 1});
  Future<Map<String, dynamic>> getCategoryServices(int categoryId,
      {int page = 1});
  Future<PaginatedCategories> getCategorySubcategories(int categoryId,
      {int page = 1});
}

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final ApiClient _api;
  CategoriesRemoteDataSourceImpl(this._api);

  @override
  Future<PaginatedCategories> getCategories({int page = 1}) async {
    try {
      final res = await _api.get(
        'customer/categories',
        queryParameters: {'page': page},
      );
      return PaginatedCategories.fromJson(res);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getCategoryServices(int categoryId,
      {int page = 1}) async {
    try {
      final res = await _api.get(
        'customer/categories/$categoryId/services',
        queryParameters: {'page': page},
      );
      return res;
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  @override
  Future<PaginatedCategories> getCategorySubcategories(int categoryId,
      {int page = 1}) async {
    try {
      final res = await _api.get(
        'customer/categories/$categoryId/sub',
        queryParameters: {'page': page},
      );
      return PaginatedCategories.fromJson(res);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}