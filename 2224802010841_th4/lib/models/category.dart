import 'package:flutter/material.dart';

class NewsCategory {
  final String name;
  final String rssUrl;
  final IconData icon;
  final Color color;

  const NewsCategory({
    required this.name,
    required this.rssUrl,
    required this.icon,
    required this.color,
  });

  static const List<NewsCategory> all = [
    NewsCategory(
      name: 'Thế giới',
      rssUrl: 'https://vnexpress.net/rss/the-gioi.rss',
      icon: Icons.public,
      color: Color(0xFF1565C0),
    ),
    NewsCategory(
      name: 'Thời sự',
      rssUrl: 'https://vnexpress.net/rss/thoi-su.rss',
      icon: Icons.newspaper,
      color: Color(0xFFC62828),
    ),
    NewsCategory(
      name: 'Kinh doanh',
      rssUrl: 'https://vnexpress.net/rss/kinh-doanh.rss',
      icon: Icons.trending_up,
      color: Color(0xFF2E7D32),
    ),
    NewsCategory(
      name: 'Khoa học',
      rssUrl: 'https://vnexpress.net/rss/khoa-hoc.rss',
      icon: Icons.science,
      color: Color(0xFF6A1B9A),
    ),
    NewsCategory(
      name: 'Giải trí',
      rssUrl: 'https://vnexpress.net/rss/giai-tri.rss',
      icon: Icons.movie,
      color: Color(0xFFE65100),
    ),
    NewsCategory(
      name: 'Thể thao',
      rssUrl: 'https://vnexpress.net/rss/the-thao.rss',
      icon: Icons.sports_soccer,
      color: Color(0xFF00695C),
    ),
    NewsCategory(
      name: 'Pháp luật',
      rssUrl: 'https://vnexpress.net/rss/phap-luat.rss',
      icon: Icons.gavel,
      color: Color(0xFF4E342E),
    ),
    NewsCategory(
      name: 'Giáo dục',
      rssUrl: 'https://vnexpress.net/rss/giao-duc.rss',
      icon: Icons.school,
      color: Color(0xFF0277BD),
    ),
    NewsCategory(
      name: 'Sức khoẻ',
      rssUrl: 'https://vnexpress.net/rss/suc-khoe.rss',
      icon: Icons.favorite,
      color: Color(0xFFAD1457),
    ),
    NewsCategory(
      name: 'Xe',
      rssUrl: 'https://vnexpress.net/rss/oto-xe-may.rss',
      icon: Icons.directions_car,
      color: Color(0xFF37474F),
    ),
    NewsCategory(
      name: 'Du lịch',
      rssUrl: 'https://vnexpress.net/rss/du-lich.rss',
      icon: Icons.flight,
      color: Color(0xFF0097A7),
    ),
    NewsCategory(
      name: 'Số hoá',
      rssUrl: 'https://vnexpress.net/rss/so-hoa.rss',
      icon: Icons.devices,
      color: Color(0xFF455A64),
    ),
  ];
}
