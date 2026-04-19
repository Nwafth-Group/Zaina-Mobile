import '../../../../core/network/failure.dart';
import '../datasources/search_remote_datasource.dart';
import '../model/service_model.dart';

abstract class SearchRepository {
  Future<SearchResponse> search(String query, {int page = 1});
}

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource _remote;
  SearchRepositoryImpl(this._remote);

  @override
  Future<SearchResponse> search(String query, {int page = 1}) async {
    try {
      return await _remote.search(query, page: page);
    } on Failure {
      rethrow;
    }
  }
}