
import '../../data/model/banner_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/failure.dart';
import '../../data/model/service_model.dart';
import '../../data/repository/category_repo.dart';


class CategoriesCubit extends Cubit<CategoriesState> {
  final CategoriesRepository _repo;
  CategoriesCubit(this._repo) : super(CategoriesInitial());

  List<CategoryModel> _items = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  Future<void> fetchCategories({bool refresh = false}) async {
    if (refresh) {
      _items = [];
      _currentPage = 1;
    }
    emit(CategoriesLoading());
    try {
      final res = await _repo.getCategories(page: 1);
      _items = res.items;
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      emit(CategoriesLoaded(
        categories: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } on Failure catch (e) {
      emit(CategoriesError(e.message));
    } catch (e) {
      emit(CategoriesError('Something went wrong'));
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    _loadingMore = true;
    emit(CategoriesLoadingMore(List.from(_items)));
    try {
      final res = await _repo.getCategories(page: _currentPage + 1);
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      _items.addAll(res.items);
      emit(CategoriesLoaded(
        categories: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } on Failure catch (_) {
      emit(CategoriesLoaded(
        categories: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } finally {
      _loadingMore = false;
    }
  }
}

// ── Separate cubit for services inside a category ─────────────────────────────
class CategoryServicesCubit extends Cubit<CategoryServicesState> {
  final CategoriesRepository _repo;
  CategoryServicesCubit(this._repo) : super(CategoryServicesInitial());

  List<ServiceModel> _items = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  Future<void> fetchServices(int categoryId, {bool refresh = false}) async {
    if (refresh) {
      _items = [];
      _currentPage = 1;
    }
    emit(CategoryServicesLoading());
    try {
      final raw = await _repo.getCategoryServices(categoryId, page: 1);
      final data = raw['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      _currentPage = meta['current_page'] ?? 1;
      _lastPage = meta['last_page'] ?? 1;
      _items = (data['items'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e))
          .toList();
      emit(CategoryServicesLoaded(
        services: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } on Failure catch (e) {
      emit(CategoryServicesError(e.message));
    } catch (e) {
      emit(CategoryServicesError('Something went wrong'));
    }
  }

  Future<void> loadMore(int categoryId) async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    _loadingMore = true;
    emit(CategoryServicesLoadingMore(List.from(_items)));
    try {
      final raw =
      await _repo.getCategoryServices(categoryId, page: _currentPage + 1);
      final data = raw['data'] as Map<String, dynamic>;
      final meta = data['meta'] as Map<String, dynamic>? ?? {};
      _currentPage = meta['current_page'] ?? 1;
      _lastPage = meta['last_page'] ?? 1;
      _items.addAll((data['items'] as List<dynamic>? ?? [])
          .map((e) => ServiceModel.fromJson(e))
          .toList());
      emit(CategoryServicesLoaded(
        services: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } on Failure {
      emit(CategoryServicesLoaded(
        services: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } finally {
      _loadingMore = false;
    }
  }
}

class SubcategoriesCubit extends Cubit<SubcategoriesState> {
  final CategoriesRepository _repo;
  SubcategoriesCubit(this._repo) : super(SubcategoriesInitial());

  List<CategoryModel> _items = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _loadingMore = false;

  Future<void> fetchSubcategories(int categoryId, {bool refresh = false}) async {
    if (refresh) {
      _items = [];
      _currentPage = 1;
    }
    emit(SubcategoriesLoading());
    try {
      final res = await _repo.getCategorySubcategories(categoryId, page: 1);
      _items = res.items;
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      emit(SubcategoriesLoaded(
        categories: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } on Failure catch (e) {
      emit(SubcategoriesError(e.message));
    } catch (e) {
      emit(SubcategoriesError('Something went wrong'));
    }
  }

  Future<void> loadMore(int categoryId) async {
    if (_loadingMore || _currentPage >= _lastPage) return;
    _loadingMore = true;
    emit(SubcategoriesLoadingMore(List.from(_items)));
    try {
      final res = await _repo.getCategorySubcategories(categoryId, page: _currentPage + 1);
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      _items.addAll(res.items);
      emit(SubcategoriesLoaded(
        categories: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } on Failure {
      emit(SubcategoriesLoaded(
        categories: List.from(_items),
        currentPage: _currentPage,
        lastPage: _lastPage,
      ));
    } finally {
      _loadingMore = false;
    }
  }
}

abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}
class CategoriesLoading extends CategoriesState {}
class CategoriesLoadingMore extends CategoriesState {
  final List<CategoryModel> current;
  CategoriesLoadingMore(this.current);
}
class CategoriesLoaded extends CategoriesState {
  final List<CategoryModel> categories;
  final int currentPage;
  final int lastPage;
  CategoriesLoaded({
    required this.categories,
    required this.currentPage,
    required this.lastPage,
  });
  bool get hasMore => currentPage < lastPage;
}
class CategoriesError extends CategoriesState {
  final String message;
  CategoriesError(this.message);
}

// ── Category Services ─────────────────────────────────────────────────────────
abstract class CategoryServicesState {}

class CategoryServicesInitial extends CategoryServicesState {}
class CategoryServicesLoading extends CategoryServicesState {}
class CategoryServicesLoadingMore extends CategoryServicesState {
  final List<ServiceModel> current;
  CategoryServicesLoadingMore(this.current);
}
class CategoryServicesLoaded extends CategoryServicesState {
  final List<ServiceModel> services;
  final int currentPage;
  final int lastPage;
  CategoryServicesLoaded({
    required this.services,
    required this.currentPage,
    required this.lastPage,
  });
  bool get hasMore => currentPage < lastPage;
}
class CategoryServicesError extends CategoryServicesState {
  final String message;
  CategoryServicesError(this.message);
}

abstract class SubcategoriesState {}

class SubcategoriesInitial extends SubcategoriesState {}
class SubcategoriesLoading extends SubcategoriesState {}
class SubcategoriesLoadingMore extends SubcategoriesState {
  final List<CategoryModel> current;
  SubcategoriesLoadingMore(this.current);
}
class SubcategoriesLoaded extends SubcategoriesState {
  final List<CategoryModel> categories;
  final int currentPage;
  final int lastPage;

  SubcategoriesLoaded({
    required this.categories,
    required this.currentPage,
    required this.lastPage,
  });

  bool get hasMore => currentPage < lastPage;
}
class SubcategoriesError extends SubcategoriesState {
  final String message;
  SubcategoriesError(this.message);
}