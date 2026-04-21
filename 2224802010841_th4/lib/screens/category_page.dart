import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/news_shimmer.dart';
import '../widgets/error_retry.dart';
import 'detail_page.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  NewsCategory? _selectedCategory;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategory?.name ?? 'Chủ đề'),
        leading: _selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  setState(() => _selectedCategory = null);
                  context.read<NewsProvider>().clearCategoryArticles();
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_upward_rounded),
                onPressed: _scrollToTop,
                tooltip: 'Về đầu trang',
              ),
        actions: [
          if (_selectedCategory != null)
            IconButton(
              icon: const Icon(Icons.arrow_upward_rounded),
              tooltip: 'Về đầu trang',
              onPressed: _scrollToTop,
            ),
        ],
      ),
      body: _selectedCategory == null
          ? _buildCategoryGrid()
          : _buildArticleList(),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: NewsCategory.all.length,
      itemBuilder: (context, index) {
        final cat = NewsCategory.all[index];
        return _CategoryCard(
          category: cat,
          onTap: () {
            setState(() => _selectedCategory = cat);
            context.read<NewsProvider>().loadCategoryNews(cat.rssUrl, cat.name);
          },
        );
      },
    );
  }

  Widget _buildArticleList() {
    return Consumer<NewsProvider>(
      builder: (context, provider, _) {
        if (provider.isCategoryLoading) {
          return const NewsCardShimmer();
        }

        if (provider.categoryState == LoadState.error) {
          return ErrorRetry(
            message: provider.categoryError,
            onRetry: () => provider.loadCategoryNews(
              _selectedCategory!.rssUrl,
              _selectedCategory!.name,
            ),
          );
        }

        if (provider.categoryArticles.isEmpty) {
          return const Center(child: Text('Không có tin tức'));
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadCategoryNews(
            _selectedCategory!.rssUrl,
            _selectedCategory!.name,
          ),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.categoryArticles.length,
            itemBuilder: (context, index) {
              final article = provider.categoryArticles[index];
              return NewsCard(
                article: article,
                showBadge: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailPage(article: article),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final NewsCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: isDark ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: category.color.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: category.color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
