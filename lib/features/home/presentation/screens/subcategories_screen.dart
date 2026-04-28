import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../injection_container.dart';
import '../../data/model/banner_model.dart';
import '../cubit/category_cubit.dart';
import 'services_category_screen.dart';

class SubcategoriesScreen extends StatelessWidget {
  final CategoryModel category;
  const SubcategoriesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubcategoriesCubit>(
      create: (_) => sl<SubcategoriesCubit>(),
      child: _SubcategoriesScreenView(category: category),
    );
  }
}

class _SubcategoriesScreenView extends StatefulWidget {
  final CategoryModel category;
  const _SubcategoriesScreenView({required this.category});

  @override
  State<_SubcategoriesScreenView> createState() =>
      _SubcategoriesScreenViewState();
}

class _SubcategoriesScreenViewState extends State<_SubcategoriesScreenView> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<SubcategoriesCubit>()
        .fetchSubcategories(widget.category.id, refresh: true);
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        context
            .read<SubcategoriesCubit>()
            .loadMore(widget.category.id);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return Scaffold(
      backgroundColor: ZienaColors.bg1,
      appBar: AppBar(
        backgroundColor: ZienaColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.localizedName(lang),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<SubcategoriesCubit, SubcategoriesState>(
        builder: (context, state) {
          if (state is SubcategoriesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2),
            );
          }

          if (state is SubcategoriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      size: 60, color: ZienaColors.textHint),
                  const SizedBox(height: 16),
                  Text(state.message,
                      style: const TextStyle(
                          color: ZienaColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<SubcategoriesCubit>()
                        .fetchSubcategories(widget.category.id,
                            refresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZienaColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('retry'.tr(),
                        style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final categories = state is SubcategoriesLoaded
              ? state.categories
              : state is SubcategoriesLoadingMore
                  ? state.current
                  : <CategoryModel>[];
          final isLoadingMore = state is SubcategoriesLoadingMore;

          if (categories.isEmpty && state is SubcategoriesLoaded) {
            return _buildEmpty(context);
          }

          return RefreshIndicator(
            onRefresh: () => context
                .read<SubcategoriesCubit>()
                .fetchSubcategories(widget.category.id, refresh: true),
            color: ZienaColors.primary,
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: categories.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == categories.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: ZienaColors.primary, strokeWidth: 2),
                    ),
                  );
                }

                return _CategoryCard(
                  category: categories[index],
                  onTap: () {
                    if (categories[index].hasSubcategories == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubcategoriesScreen(
                            category: categories[index],
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryServicesScreen(
                            category: categories[index],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: ZienaColors.bg2,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.category_outlined,
                color: ZienaColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'no_subcategories_found'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ZienaColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: ZienaColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              category.image != null
                  ? CachedNetworkImage(
                      imageUrl: category.image!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: ZienaColors.bg3),
                      errorWidget: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback(),
              Positioned(
                left: 18,
                bottom: 18,
                right: 18,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.localizedName(lang),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return const Center(
      child: Icon(Icons.category_rounded,
          color: ZienaColors.bg3, size: 44),
    );
  }
}
