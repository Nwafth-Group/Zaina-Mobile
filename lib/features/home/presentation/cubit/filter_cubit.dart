import '../../data/model/filter_models.dart';
import '../../data/model/banner_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/failure.dart';

abstract class FilterState {}

class FilterInitial extends FilterState {}

class FilterLocationsLoading extends FilterState {
  final FilterCubitData data;
  FilterLocationsLoading(this.data);
}

class FilterLocationsLoaded extends FilterState {
  final FilterCubitData data;
  FilterLocationsLoaded(this.data);
}

class FilterError extends FilterState {
  final String message;
  FilterError(this.message);
}

// ── Holds all picker data ─────────────────────────────────────────────────────
class FilterCubitData {
  final List<LocationItem> countries;
  final List<LocationItem> governorates;
  final List<LocationItem> cities;
  final List<LocationItem> areas;
  final List<CategoryModel> categories;
  final bool countriesLoading;
  final bool governoratesLoading;
  final bool citiesLoading;
  final bool areasLoading;
  final bool categoriesLoading;

  const FilterCubitData({
    this.countries            = const [],
    this.governorates         = const [],
    this.cities               = const [],
    this.areas                = const [],
    this.categories           = const [],
    this.countriesLoading     = false,
    this.governoratesLoading  = false,
    this.citiesLoading        = false,
    this.areasLoading         = false,
    this.categoriesLoading    = false,
  });

  FilterCubitData copyWith({
    List<LocationItem>? countries,
    List<LocationItem>? governorates,
    List<LocationItem>? cities,
    List<LocationItem>? areas,
    List<CategoryModel>? categories,
    bool? countriesLoading,
    bool? governoratesLoading,
    bool? citiesLoading,
    bool? areasLoading,
    bool? categoriesLoading,
  }) {
    return FilterCubitData(
      countries:            countries            ?? this.countries,
      governorates:         governorates         ?? this.governorates,
      cities:               cities               ?? this.cities,
      areas:                areas                ?? this.areas,
      categories:           categories           ?? this.categories,
      countriesLoading:     countriesLoading     ?? this.countriesLoading,
      governoratesLoading:  governoratesLoading  ?? this.governoratesLoading,
      citiesLoading:        citiesLoading        ?? this.citiesLoading,
      areasLoading:         areasLoading         ?? this.areasLoading,
      categoriesLoading:    categoriesLoading    ?? this.categoriesLoading,
    );
  }
}

class FilterCubit extends Cubit<FilterState> {
  final ApiClient _api;
  FilterCubit(this._api) : super(FilterInitial());

  FilterCubitData _data = const FilterCubitData();
  FilterCubitData get data => _data;

  // ── Load categories ───────────────────────────────────────────────────────
  Future<void> loadCategories() async {
    if (_data.categories.isNotEmpty) return; // already loaded
    _data = _data.copyWith(categoriesLoading: true);
    emit(FilterLocationsLoading(_data));
    try {
      final res = await _api.get('customer/categories', queryParameters: {'page': 1});
      final items = (res['data']['items'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(e))
          .toList();
      _data = _data.copyWith(categoriesLoading: false, categories: items);
      emit(FilterLocationsLoaded(_data));
    } on DioException catch (e) {
      _data = _data.copyWith(categoriesLoading: false);
      emit(FilterError(handleDioError(e).message));
      emit(FilterLocationsLoaded(_data));
    } catch (_) {
      _data = _data.copyWith(categoriesLoading: false);
      emit(FilterLocationsLoaded(_data));
    }
  }

  // ── Load countries ─────────────────────────────────────────────────────────
  Future<void> loadCountries() async {
    if (_data.countries.isNotEmpty) return;
    _data = _data.copyWith(countriesLoading: true);
    emit(FilterLocationsLoading(_data));
    try {
      final res = await _api.get('customer/locations/countries');
      final items = (res['data']['items'] as List<dynamic>? ?? [])
          .map((e) => LocationItem.fromJson(e))
          .toList();
      _data = _data.copyWith(countriesLoading: false, countries: items);
      emit(FilterLocationsLoaded(_data));
    } on DioException catch (e) {
      _data = _data.copyWith(countriesLoading: false);
      emit(FilterError(handleDioError(e).message));
      emit(FilterLocationsLoaded(_data));
    } catch (_) {
      _data = _data.copyWith(countriesLoading: false);
      emit(FilterLocationsLoaded(_data));
    }
  }

  // ── Load governorates for a country ───────────────────────────────────────
  Future<void> loadGovernates(int countryId) async {
    _data = _data.copyWith(governoratesLoading: true, governorates: [], cities: [], areas: []);
    emit(FilterLocationsLoading(_data));
    try {
      final res = await _api.get(
        'customer/locations/governorates',
        queryParameters: {'country_id': countryId},
      );
      final items = (res['data']['items'] as List<dynamic>? ?? [])
          .map((e) => LocationItem.fromJson(e))
          .toList();
      _data = _data.copyWith(governoratesLoading: false, governorates: items);
      emit(FilterLocationsLoaded(_data));
    } on DioException catch (e) {
      _data = _data.copyWith(governoratesLoading: false);
      emit(FilterError(handleDioError(e).message));
      emit(FilterLocationsLoaded(_data));
    } catch (_) {
      _data = _data.copyWith(governoratesLoading: false);
      emit(FilterLocationsLoaded(_data));
    }
  }

  // ── Load cities for a governorate ──────────────────────────────────────────
  Future<void> loadCities({int? governorateId}) async {
    _data = _data.copyWith(citiesLoading: true, cities: [], areas: []);
    emit(FilterLocationsLoading(_data));
    try {
      final params = <String, dynamic>{};
      if (governorateId != null) params['govrenrate_id'] = governorateId;

      final res = await _api.get(
        'customer/locations/cities',
        queryParameters: params,
      );
      final cities = (res['data']['items'] as List<dynamic>? ?? [])
          .map((e) => LocationItem.fromJson(e))
          .toList();
      _data = _data.copyWith(citiesLoading: false, cities: cities);
      emit(FilterLocationsLoaded(_data));
    } on DioException catch (e) {
      _data = _data.copyWith(citiesLoading: false);
      emit(FilterError(handleDioError(e).message));
      emit(FilterLocationsLoaded(_data));
    } catch (_) {
      _data = _data.copyWith(citiesLoading: false);
      emit(FilterLocationsLoaded(_data));
    }
  }

  // ── Load areas for a city ─────────────────────────────────────────────────
  Future<void> loadAreas(int cityId) async {
    _data = _data.copyWith(areasLoading: true, areas: []);
    emit(FilterLocationsLoading(_data));
    try {
      final res = await _api.get(
        'customer/locations/areas',
        queryParameters: {'city_id': cityId},
      );
      final areas = (res['data']['items'] as List<dynamic>? ?? [])
          .map((e) => LocationItem.fromJson(e))
          .toList();
      _data = _data.copyWith(areasLoading: false, areas: areas);
      emit(FilterLocationsLoaded(_data));
    } on DioException catch (e) {
      _data = _data.copyWith(areasLoading: false);
      emit(FilterError(handleDioError(e).message));
      emit(FilterLocationsLoaded(_data));
    } catch (_) {
      _data = _data.copyWith(areasLoading: false);
      emit(FilterLocationsLoaded(_data));
    }
  }
}