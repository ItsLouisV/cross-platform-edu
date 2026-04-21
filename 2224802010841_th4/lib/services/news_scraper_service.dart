import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter/foundation.dart';

class NewsScraperService {
  static final NewsScraperService _instance = NewsScraperService._internal();
  factory NewsScraperService() => _instance;
  NewsScraperService._internal();

  /// Fetches the full content of a VnExpress article
  Future<List<String>> fetchFullContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      // Parse the HTML document
      var document = parse(response.body);
      
      // VnExpress structure:
      // Content is usually inside <article class="fck_detail"> 
      // or has many <p class="Normal"> tags
      
      List<String> paragraphs = [];
      
      // Method 1: Find the main article body
      var articleBody = document.querySelector('article.fck_detail');
      
      if (articleBody != null) {
        // Extract all <p class="Normal"> inside the body
        var pTags = articleBody.querySelectorAll('p.Normal');
        for (var p in pTags) {
          String text = p.text.trim();
          if (text.isNotEmpty) {
            paragraphs.add(text);
          }
        }
      } 
      
      // Method 2 Fallback: Just find all <p class="Normal"> in the whole document
      if (paragraphs.isEmpty) {
        var allNormalP = document.querySelectorAll('p.Normal');
        for (var p in allNormalP) {
          String text = p.text.trim();
          if (text.isNotEmpty && !text.contains('Video:') && !text.contains('Ảnh:')) {
            paragraphs.add(text);
          }
        }
      }

      // Log for debugging
      debugPrint('Scraped ${paragraphs.length} paragraphs from $url');
      
      return paragraphs;
    } catch (e) {
      debugPrint('Error scraping article: $e');
      return [];
    }
  }
}
