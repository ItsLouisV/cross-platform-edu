import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';
import '../models/article.dart';
import '../utils/date_formatter.dart';
import '../services/news_scraper_service.dart';

class DetailPage extends StatefulWidget {
  final Article article;

  const DetailPage({super.key, required this.article});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final NewsScraperService _scraperService = NewsScraperService();
  List<String>? _fullContent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullContent();
  }

  Future<void> _loadFullContent() async {
    final content = await _scraperService.fetchFullContent(widget.article.link);
    if (mounted) {
      setState(() {
        _fullContent = content;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero Image AppBar
          SliverAppBar(
            expandedHeight: widget.article.imageUrl.isNotEmpty ? 300 : 120,
            pinned: true,
            stretch: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              _buildAppBarAction(
                context, 
                icon: Icons.share_rounded, 
                onPressed: () => Share.share('${widget.article.title}\n${widget.article.link}'),
              ),
              _buildAppBarAction(
                context, 
                icon: Icons.open_in_browser_rounded, 
                onPressed: () => _openUrl(widget.article.link),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.article.imageUrl.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: widget.article.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 50),
                      ),
                    )
                  else
                    Container(color: colorScheme.primary.withValues(alpha: 0.1)),
                  
                  // Gradient Overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
                          theme.scaffoldBackgroundColor,
                        ],
                        stops: const [0.0, 0.3, 0.85, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Reading Time Row
                  Row(
                    children: [
                      if (widget.article.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.article.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      const SizedBox(width: 12),
                      Icon(Icons.auto_stories_rounded, size: 14, color: colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        widget.article.readingTime,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Metadata Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.primary,
                          child: const Icon(Icons.newspaper_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.article.source,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                DateFormatter.formatFull(widget.article.pubDate),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description / Lead
                  Text(
                    widget.article.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 18,
                      height: 1.8,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),

                  // Full Content
                  if (_isLoading)
                    _buildContentShimmer(isDark)
                  else if (_fullContent == null || _fullContent!.isEmpty)
                    _buildErrorState(theme)
                  else
                    ..._fullContent!.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        p,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 17,
                          height: 1.7,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                        ),
                      ),
                    )),

                  const SizedBox(height: 40),

                  // Action Buttons
                  _buildPrimaryButton(
                    context,
                    label: 'Mở bài gốc trên ${widget.article.source}',
                    icon: Icons.open_in_new_rounded,
                    onPressed: () => _openUrl(widget.article.link),
                  ),
                  const SizedBox(height: 12),
                  _buildSecondaryButton(
                    context,
                    label: 'Chia sẻ bài viết',
                    icon: Icons.share_rounded,
                    onPressed: () => Share.share('${widget.article.title}\n${widget.article.link}'),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(5, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: double.infinity, height: 14, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 14, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: MediaQuery.of(context).size.width * 0.6, height: 14, color: Colors.white),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Column(
      children: [
        const Icon(Icons.info_outline_rounded, size: 40, color: Colors.grey),
        const SizedBox(height: 8),
        Text(
          'Không thể tải nội dung chi tiết. Bạn có thể xem bài viết gốc trên trình duyệt.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildAppBarAction(BuildContext context, {required IconData icon, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        child: IconButton(
          icon: Icon(icon, size: 18, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
