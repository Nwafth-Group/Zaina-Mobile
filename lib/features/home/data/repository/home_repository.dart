import '../../../../core/network/failure.dart';
import '../datasources/home_datasource.dart';
import '../model/banner_model.dart';

abstract class HomeRepository {
  Future<HomeData> getHomeData();
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remote;
  HomeRepositoryImpl(this._remote);

  @override
  Future<HomeData> getHomeData() async {
    try {
      return await _remote.getHomeData();
    } on Failure {
      rethrow;
    }
  }
}