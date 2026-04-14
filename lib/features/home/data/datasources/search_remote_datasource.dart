import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';
import '../model/service_model.dart';

abstract class SearchRemoteDataSource {
  Future<SearchResponse> search(String query, {int page = 1});
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final ApiClient _api;
  SearchRemoteDataSourceImpl(this._api);

  @override
  Future<SearchResponse> search(String query, {int page = 1}) async {
    try {
      final response = await _api.get(
        'customer/search',
        queryParameters: {
          'search': query,
          'page': page,
        },
      );
      return SearchResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }
}