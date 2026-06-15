import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zeina/features/home/presentation/screens/services_category_screen.dart';
import 'package:zeina/features/home/presentation/screens/subcategories_screen.dart';
import '../../../../core/theme/theme.dart';
import '../../../../widgets/ziena_logo.dart';
import '../../data/model/banner_model.dart';
import '../cubit/category_cubit.dart';

class ServiceCategoriesScreen extends StatefulWidget {
  static const String routeName = '/categories';
  const ServiceCategoriesScreen({super.key});

  @override
  State<ServiceCategoriesScreen> createState() =>
      _ServiceCategoriesScreenState();
}

class _ServiceCategoriesScreenState extends State<ServiceCategoriesScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<CategoriesCubit>().fetchCategories(refresh: true);
    _scroll.addListener(() {
      if (_scroll.position.pixels >=
          _scroll.position.maxScrollExtent - 200) {
        context.read<CategoriesCubit>().loadMore();
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: ZienaColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'service_categories'.tr(),
          style: const TextStyle(
            
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ZienaColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          // ── Loading ──────────────────────────────────────────────────────
          if (state is CategoriesLoading) {
            return const Center(
              child: CircularProgressIndicator(
                  color: ZienaColors.primary, strokeWidth: 2),
            );
          }

          // ── Error ────────────────────────────────────────────────────────
          if (state is CategoriesError) {
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
                        .read<CategoriesCubit>()
                        .fetchCategories(refresh: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ZienaColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('retry'.tr(),
                        style: const TextStyle(
                             color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          // ── Loaded + LoadingMore ──────────────────────────────────────────
          final categories = state is CategoriesLoaded
              ? state.categories
              : state is CategoriesLoadingMore
              ? state.current
              : <CategoryModel>[];

          final isLoadingMore = state is CategoriesLoadingMore;

          return RefreshIndicator(
            onRefresh: () => context
                .read<CategoriesCubit>()
                .fetchCategories(refresh: true),
            color: ZienaColors.primary,
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              itemCount: categories.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == categories.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                          color: ZienaColors.primary, strokeWidth: 2),
                    ),
                  );
                }
                return _CategoryCard(
                  category: categories[i],
                  onTap: () {
                    if (categories[i].hasSubcategories == true) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubcategoriesScreen(
                            category: categories[i],
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryServicesScreen(
                            category: categories[i],
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
}

// ── Category Card ─────────────────────────────────────────────────────────────
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
              // ── Background image ────────────────────────────────────────
              category.image != null
                  ? CachedNetworkImage(
                imageUrl: category.image!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: ZienaColors.bg3),
                errorWidget: (_, _, _) => _imageFallback(),
              )
                  : _imageFallback(),


              // ── Name + arrow ────────────────────────────────────────────
              Positioned(
                left: 18,
                bottom: 18,
                right: 18,
                child: gradientBlurContainer(
                  color: Colors.white10,
                  circular: 10,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.localizedName(lang),
                          style: const TextStyle(

                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
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