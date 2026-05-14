import '../../data/model/service_model.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/failure.dart';
import '../../data/repository/search_repository.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _repo;
  SearchCubit(this._repo) : super(SearchInitial());

  Timer? _debounce;
  List<ServiceModel> _currentResults = [];
  String _currentQuery = '';
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;

  // ── Debounced search triggered on every keystroke ──────────────────────────
  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _currentQuery = '';
      _fetchSuggestions();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      search(query);
    });
  }

  // ── Fetch suggestions (empty query) ───────────────────────────────────────
  Future<void> _fetchSuggestions() async {
    emit(SearchLoading());
    try {
      final res = await _repo.search('');
      if (res.isSuggestions) {
        emit(SearchSuggestions(res.suggestions));
      } else {
        emit(SearchInitial());
      }
    } on Failure catch (e) {
      emit(SearchError(e.message));
    } catch (_) {
      emit(SearchInitial());
    }
  }

  // ── Full search (first page) ───────────────────────────────────────────────
  Future<void> search(String query, {int page = 1}) async {
    _currentQuery = query.trim();
    _currentPage = 1;
    _currentResults = [];

    emit(SearchLoading());
    try {
      final res = await _repo.search(_currentQuery, page: 1);

      if (res.isSuggestions) {
        emit(SearchSuggestions(res.suggestions));
        return;
      }

      _lastPage = res.lastPage;
      _currentPage = res.currentPage;
      _currentResults = res.services;

      if (_currentResults.isEmpty) {
        emit(SearchEmpty(_currentQuery));
      } else {
        emit(SearchResults(
          results: List.from(_currentResults),
          query: _currentQuery,
          currentPage: _currentPage,
          lastPage: _lastPage,
          total: res.total,
        ));
      }
    } on Failure catch (e) {
      emit(SearchError(e.message));
    } catch (e) {
      emit(SearchError('Something went wrong. Please try again.'));
    }
  }

  // ── Load next page (pagination) ────────────────────────────────────────────
  Future<void> loadMore() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;
    _isLoadingMore = true;

    emit(SearchLoadingMore(List.from(_currentResults)));
    try {
      final res =
      await _repo.search(_currentQuery, page: _currentPage + 1);
      _currentPage = res.currentPage;
      _lastPage = res.lastPage;
      _currentResults.addAll(res.services);

      emit(SearchResults(
        results: List.from(_currentResults),
        query: _currentQuery,
        currentPage: _currentPage,
        lastPage: _lastPage,
        total: res.total,
      ));
    } on Failure {
      // Restore previous results on error
      emit(SearchResults(
        results: List.from(_currentResults),
        query: _currentQuery,
        currentPage: _currentPage,
        lastPage: _lastPage,
        total: _currentResults.length,
      ));
    } finally {
      _isLoadingMore = false;
    }
  }

  void clear() {
    _debounce?.cancel();
    _currentResults = [];
    _currentQuery = '';
    emit(SearchInitial());
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoadingMore extends SearchState {
  final List<ServiceModel> currentResults;
  SearchLoadingMore(this.currentResults);
}

class SearchSuggestions extends SearchState {
  final List<String> suggestions;
  SearchSuggestions(this.suggestions);
}

class SearchResults extends SearchState {
  final List<ServiceModel> results;
  final String query;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  SearchResults({
    required this.results,
    required this.query,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  }) : hasMore = currentPage < lastPage;
}

class SearchEmpty extends SearchState {
  final String query;
  SearchEmpty(this.query);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

