import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';
import '../widgets/news_shimmer.dart';
import '../widgets/error_retry.dart';
import '../utils/date_formatter.dart';
import 'detail_page.dart';

class LatestPage extends StatefulWidget {
  const LatestPage({super.key});

  @override
  State<LatestPage> createState() => _LatestPageState();
}

class _LatestPageState extends State<LatestPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadLatestNews();
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_upward_rounded),
          tooltip: 'Về đầu trang',
          onPressed: _scrollToTop,
        ),
        title: const Text('Tin mới nhất'),
        actions: [
          Consumer<NewsProvider>(
            builder: (context, provider, _) => IconButton(
              icon: provider.isLatestLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
              onPressed: provider.isLatestLoading
                  ? null
                  : () => provider.loadLatestNews(forceRefresh: true),
            ),
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLatestLoading && provider.latestArticles.isEmpty) {
            return const NewsCardShimmer();
          }

          if (provider.latestState == LoadState.error &&
              provider.latestArticles.isEmpty) {
            return ErrorRetry(
              message: provider.latestError,
              onRetry: () => provider.loadLatestNews(forceRefresh: true),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadLatestNews(forceRefresh: true),
            child: Column(
              children: [
                // "Updated at" bar
                if (provider.latestArticles.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    child: Row(
                      children: [
                        Icon(Icons.update_rounded,
                            size: 15,
                            color: theme.colorScheme.onPrimaryContainer),
                        const SizedBox(width: 6),
                        Text(
                          'Cập nhật lúc ${DateFormatter.formatTime(DateTime.now())} · ${provider.latestArticles.length} tin mới nhất',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Article list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: provider.latestArticles.length,
                    itemBuilder: (context, index) {
                      final article = provider.latestArticles[index];
                      return Stack(
                        children: [
                          NewsCard(
                            article: article,
                            showBadge: true,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPage(article: article),
                              ),
                            ),
                          ),
                          // Index number badge
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 4,
                              color: index == 0
                                  ? Colors.red
                                  : index < 3
                                      ? Colors.orange
                                      : Colors.transparent,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
