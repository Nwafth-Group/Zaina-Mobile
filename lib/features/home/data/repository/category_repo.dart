import '../../../../core/network/failure.dart';
import '../datasources/categories_remote_datasource.dart';
import '../model/banner_model.dart';

abstract class CategoriesRepository {
  Future<PaginatedCategories> getCategories({int page = 1});
  Future<Map<String, dynamic>> getCategoryServices(int categoryId,
      {int page = 1});
  Future<PaginatedCategories> getCategorySubcategories(int categoryId,
      {int page = 1});
}

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _remote;
  CategoriesRepositoryImpl(this._remote);

  @override
  Future<PaginatedCategories> getCategories({int page = 1}) async {
    try {
      return await _remote.getCategories(page: page);
    } on Failure {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCategoryServices(int categoryId,
      {int page = 1}) async {
    try {
      return await _remote.getCategoryServices(categoryId, page: page);
    } on Failure {
      rethrow;
    }
  }

  @override
  Future<PaginatedCategories> getCategorySubcategories(int categoryId,
      {int page = 1}) async {
    try {
      return await _remote.getCategorySubcategories(categoryId, page: page);
    } on Failure {
      rethrow;
    }
  }
}