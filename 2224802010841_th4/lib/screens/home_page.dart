import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/news_shimmer.dart';
import '../widgets/error_retry.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadHomeNews();
    });
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_upward_rounded),
          tooltip: 'Về đầu trang',
          onPressed: _scrollToTop,
        ),
        title: const Text('VanLinh News'),
        actions: [
          Consumer<NewsProvider>(
            builder: (context, provider, _) => IconButton(
              icon: provider.isHomeLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
              tooltip: 'Làm mới',
              onPressed: provider.isHomeLoading
                  ? null
                  : () => provider.loadHomeNews(forceRefresh: true),
            ),
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.homeState == LoadState.loading &&
              provider.homeArticles.isEmpty) {
            return const NewsCardShimmer();
          }

          if (provider.homeState == LoadState.error &&
              provider.homeArticles.isEmpty) {
            return ErrorRetry(
              message: provider.homeError,
              onRetry: () => provider.loadHomeNews(forceRefresh: true),
            );
          }

          if (provider.homeArticles.isEmpty) {
            return const Center(child: Text('Không có tin tức'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadHomeNews(forceRefresh: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.homeArticles.length,
              itemBuilder: (context, index) {
                final article = provider.homeArticles[index];
                return NewsCard(
                  article: article,
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
      ),
    );
  }
}
