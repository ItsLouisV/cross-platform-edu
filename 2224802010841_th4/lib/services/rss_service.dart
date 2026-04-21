import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/article.dart';

class RssService {
  static const String _baseUrl = 'https://vnexpress.net/rss';
  static const String _allNewsUrl = '$_baseUrl/tin-moi-nhat.rss';

  // CORS proxy dùng cho Flutter Web.
  // allorigins.win là free proxy, không cần cài gì thêm.
  // Nếu bị chặn, đổi sang: 'https://corsproxy.io/?'
  static const String _corsProxy = 'https://api.allorigins.win/raw?url=';

  static final RssService _instance = RssService._internal();
  factory RssService() => _instance;
  RssService._internal();

  /// Trả về URL đã wrap qua proxy nếu đang chạy trên web
  String _resolveUrl(String originalUrl) {
    if (kIsWeb) {
      return '$_corsProxy${Uri.encodeComponent(originalUrl)}';
    }
    return originalUrl;
  }

  Future<List<Article>> fetchFeed(String url, String category) async {
    final resolvedUrl = _resolveUrl(url);
    try {
      final response = await http
          .get(
            Uri.parse(resolvedUrl),
            headers: kIsWeb
                ? {} // Không set User-Agent trên web (browser tự set)
                : {
                    'User-Agent': 'DocBaoOnline/1.0',
                    'Accept': 'application/rss+xml, application/xml, text/xml',
                  },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return _parseRss(response.body, category);
      }
      throw Exception('HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Không thể tải tin tức: $e');
    }
  }

  Future<List<Article>> fetchAllNews() async {
    return fetchFeed(_allNewsUrl, 'Tất cả');
  }

  Future<List<Article>> fetchLatest({int limit = 10}) async {
    final articles = await fetchAllNews();
    articles.sort((a, b) => b.pubDate.compareTo(a.pubDate));
    return articles.take(limit).toList();
  }

  List<Article> _parseRss(String xmlString, String category) {
    final articles = <Article>[];
    try {
      final document = XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');
      for (final item in items) {
        try {
          articles.add(Article.fromXmlItem(item, category));
        } catch (_) {
          // skip malformed items
        }
      }
    } catch (e) {
      throw Exception('Lỗi parse XML: $e');
    }
    return articles;
  }
}
