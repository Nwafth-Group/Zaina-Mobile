import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/custom_text_form_field.dart';
import '../../data/model/service_model.dart';
import '../cubit/search_cubit.dart';
import '../widgets/service_result_card.dart';

class SearchScreen extends StatefulWidget {
  static const String routeName = '/search';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load suggestions on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      context.read<SearchCubit>().onQueryChanged('');
    });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      context.read<SearchCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onClear() {
    _ctrl.clear();
    context.read<SearchCubit>().onQueryChanged('');
    _focus.requestFocus();
  }

  void _onSuggestionTap(String s) {
    _ctrl.text = s;
    _ctrl.selection =
        TextSelection.fromPosition(TextPosition(offset: s.length));
    context.read<SearchCubit>().search(s);
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZienaColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  // ── Loading (first page) ──────────────────────────────
                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: ZienaColors.primary, strokeWidth: 2),
                    );
                  }

                  // ── Suggestions ───────────────────────────────────────
                  if (state is SearchSuggestions || state is SearchInitial) {
                    final chips = state is SearchSuggestions
                        ? state.suggestions
                        : <String>[];
                    return _buildSuggestions(chips);
                  }

                  // ── No results ────────────────────────────────────────
                  if (state is SearchEmpty) {
                    return _buildNoResults(state.query);
                  }

                  // ── Results + load-more ───────────────────────────────
                  if (state is SearchResults ||
                      state is SearchLoadingMore) {
                    final results = state is SearchResults
                        ? state.results
                        : (state as SearchLoadingMore).currentResults;
                    final hasMore = state is SearchResults
                        ? state.hasMore
                        : true;
                    return _buildResults(results, loadingMore: hasMore && state is SearchLoadingMore);
                  }

                  // ── Error ─────────────────────────────────────────────
                  if (state is SearchError) {
                    return Center(
                      child: Text(state.message,
                          style: const TextStyle(
                              
                              color: ZienaColors.textSecondary)),
                    );
                  }

                  return _buildSuggestions([]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: ZienaColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: ZienaColors.textPrimary),
          ),
          const SizedBox(width: 12),

          // Search Field using CustomTextField
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _ctrl,
              builder: (context, value, _) {
                return CustomTextField(
                  controller: _ctrl,
                  hintText: 'search'.tr(),
                  onChanged: (q) => context.read<SearchCubit>().onQueryChanged(q),
                  // Note: CustomTextField currently uses TextFormField which uses
                  // onFieldSubmitted, but your snippet showed onChanged.
                  // If you need onSubmitted, you might need to add it to your CustomTextField class.
                  prefixIcon: const Icon(Icons.search, color: ZienaColors.primary, size: 20),
                  suffixIcon: value.text.isNotEmpty
                      ? GestureDetector(
                    onTap: _onClear,
                    child: const Icon(Icons.cancel, color: ZienaColors.textSecondary, size: 20),
                  )
                      : GestureDetector(
                    onTap: () {
                      // Handle filter logic
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Matched the rounded style of your custom field
                      ),
                      child: const Icon(Icons.tune_rounded,
                          color: ZienaColors.primary, size: 20),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Suggestions state ───────────────────────────────────────────────────────
  Widget _buildSuggestions(List<String> chips) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'suggestions'.tr(),
            style: const TextStyle(
              
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips
                .map((s) => _SuggestionChip(
              label: s,
              onTap: () => _onSuggestionTap(s),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── No results state ────────────────────────────────────────────────────────
  Widget _buildNoResults(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: ZienaColors.bg2,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.search_off_rounded,
                    size: 80,
                    color: ZienaColors.primary.withOpacity(0.45),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: ZienaColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_services_found'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ZienaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'try_different_search'.tr(),
              style: const TextStyle(
                fontSize: 13,
                color: ZienaColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Results state ───────────────────────────────────────────────────────────
  Widget _buildResults(List<ServiceModel> results,
      {bool loadingMore = false}) {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: results.length + (loadingMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2),
            ),
          );
        }
        return ServiceResultCard(
          service: results[i],
          onTap: () {
          //   Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) =>
          //         ServiceDetailScreen(service: results[i]),
          //   ),
          // );
          }
        );
      },
    );
  }
}

// ── Chip widget ───────────────────────────────────────────────────────────────
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: ZienaColors.bg1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ZienaColors.bg4, width: 0.8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ZienaColors.textPrimary,
          ),
        ),
      ),
    );
  }
}