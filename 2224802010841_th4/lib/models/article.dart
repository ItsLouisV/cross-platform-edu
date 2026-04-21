import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';

class Article {
  final String title;
  final String description;
  final String link;
  final String imageUrl;
  final String source;
  final String category;
  final DateTime pubDate;

  Article({
    required this.title,
    required this.description,
    required this.link,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.pubDate,
  });

  factory Article.fromXmlItem(dynamic item, String category) {
    String title = _getText(item, 'title');
    String rawDescription = _getText(item, 'description');
    String link = _getLink(item);
    String pubDateStr = _getText(item, 'pubDate');

    // Extract ảnh TRƯỚC khi clean HTML
    String imageUrl = _extractImage(rawDescription, item);

    // Clean HTML tags trong description
    String description = rawDescription
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (title.isEmpty) {
      title = description.isNotEmpty
          ? (description.length > 80
              ? '${description.substring(0, 80)}...'
              : description)
          : 'Tin tức VnExpress';
    }
    if (description.isEmpty) {
      description = 'Nhấn để đọc toàn bộ bài viết trên VnExpress...';
    }

    DateTime pubDate;
    try {
      pubDate = _parseRssDate(pubDateStr);
    } catch (_) {
      pubDate = DateTime.now();
    }

    final article = Article(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      source: 'VnExpress',
      category: category,
      pubDate: pubDate,
    );

    // // Logging for debug
    // debugPrint('--- PARSED ARTICLE ---');
    // debugPrint('Title: ${article.title}');
    // debugPrint('Image: ${article.imageUrl}');
    // debugPrint('Desc: ${article.description.length > 50 ? article.description.substring(0, 50) : article.description}...');
    // debugPrint('----------------------');

    return article;
  }

  // Đọc text/CDATA. package:xml tự unwrap CDATA qua innerText.
  static String _getText(dynamic item, String tag) {
    try {
      // In ra XML thô để kiểm tra (chỉ in 1 lần hoặc 1 phần để tránh quá tải log)
      // debugPrint('RAW ITEM: ${item.toXmlString()}'); 

      // Tìm thẻ theo local name (bỏ qua namespace nếu có)
      final els = item.children.whereType<XmlElement>().where((e) => e.name.local.toLowerCase() == tag.toLowerCase());
      if (els.isEmpty) return '';
      return els.first.text.trim();
    } catch (e) {
      debugPrint('Error in _getText for $tag: $e');
      return '';
    }
  }

  // Link trong VnExpress RSS đôi khi không nằm trong CDATA → cần xử lý riêng
  static String _getLink(dynamic item) {
    try {
      final els = item.children.whereType<XmlElement>().where((e) => e.name.local.toLowerCase() == 'link');
      if (els.isEmpty) return '';
      final el = els.first;

      final inner = el.text.trim();
      if (inner.startsWith('http')) return inner;

      // Đọc từng child node
      for (final child in el.children) {
        final val = child.value?.trim() ?? '';
        if (val.startsWith('http')) return val;
      }

      // Fallback: dùng regex tìm URL trong raw XML
      final raw = el.toXmlString();
      final urlMatch = RegExp(r'https?://[^\s<>"]+').firstMatch(raw);
      if (urlMatch != null) return urlMatch.group(0)!;
    } catch (_) {}
    return '';
  }

  // Extract URL ảnh — VnExpress thường nhúng ảnh trong description HTML
  static String _extractImage(String rawDescription, dynamic item) {
    // 1. <enclosure url="..." />
    try {
      final enclosures = item.children.whereType<XmlElement>().where((e) => e.name.local.toLowerCase() == 'enclosure');
      for (final el in enclosures) {
        final url = el.getAttribute('url') ?? '';
        if (url.isNotEmpty) return url;
      }
    } catch (_) {}

    // 2. <media:content> hoặc <media:thumbnail>
    try {
      final mediaTags = ['content', 'thumbnail'];
      final mediaEls = item.children.whereType<XmlElement>().where((e) => mediaTags.contains(e.name.local.toLowerCase()));
      for (final el in mediaEls) {
        final url = el.getAttribute('url') ?? '';
        if (url.isNotEmpty && _isImageUrl(url)) return url;
      }
    } catch (_) {}

    // 3. <img src="..."> trong description HTML — VnExpress hay dùng cách này
    try {
      final patterns = [
        RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false),
        RegExp(r"<img[^>]+src='([^']+)'", caseSensitive: false),
      ];
      for (final re in patterns) {
        final match = re.firstMatch(rawDescription);
        if (match != null) {
          final url = match.group(1) ?? '';
          if (url.isNotEmpty) return url;
        }
      }
    } catch (_) {}

    return '';
  }

  static bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.webp') ||
        lower.contains('.gif');
  }

  // Parse RFC 2822: "Mon, 21 Apr 2026 10:30:00 +0700"
  static DateTime _parseRssDate(String dateStr) {
    if (dateStr.isEmpty) return DateTime.now();
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}
    try {
      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final cleaned = dateStr.contains(',')
          ? dateStr.substring(dateStr.indexOf(',') + 1).trim()
          : dateStr.trim();
      final parts = cleaned.split(RegExp(r'\s+'));
      if (parts.length >= 4) {
        final day = int.parse(parts[0]);
        final month = months[parts[1]] ?? 1;
        final year = int.parse(parts[2]);
        final timeParts = parts[3].split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
        int tzOffsetMinutes = 0;
        if (parts.length >= 5) {
          final tz = parts[4];
          final sign = tz.startsWith('-') ? -1 : 1;
          final tzStr = tz.replaceAll(RegExp(r'[+-]'), '');
          if (tzStr.length >= 4) {
            tzOffsetMinutes = sign *
                (int.parse(tzStr.substring(0, 2)) * 60 +
                    int.parse(tzStr.substring(2, 4)));
          }
        }
        final utc = DateTime.utc(year, month, day, hour, minute, second);
        return utc.add(Duration(minutes: -tzOffsetMinutes));
      }
    } catch (_) {}
    return DateTime.now();
  }

  bool get isNew => DateTime.now().difference(pubDate).inHours < 1;

  String get readingTime {
    final wordCount = description.split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil();
    return '$minutes phút đọc';
  }
}