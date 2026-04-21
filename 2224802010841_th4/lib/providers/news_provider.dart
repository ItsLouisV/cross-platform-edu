import 'package:flutter/foundation.dart';
import '../models/article.dart';
import '../services/rss_service.dart';

enum LoadState { idle, loading, success, error }

class NewsProvider extends ChangeNotifier {
  final RssService _service = RssService();

  List<Article> _homeArticles = [];
  List<Article> _latestArticles = [];
  List<Article> _categoryArticles = [];

  LoadState _homeState = LoadState.idle;
  LoadState _latestState = LoadState.idle;
  LoadState _categoryState = LoadState.idle;

  String _homeError = '';
  String _latestError = '';
  String _categoryError = '';

  String _currentCategoryName = '';
  DateTime? _lastHomeRefresh;

  // Getters
  List<Article> get homeArticles => _homeArticles;
  List<Article> get latestArticles => _latestArticles;
  List<Article> get categoryArticles => _categoryArticles;

  LoadState get homeState => _homeState;
  LoadState get latestState => _latestState;
  LoadState get categoryState => _categoryState;

  String get homeError => _homeError;
  String get latestError => _latestError;
  String get categoryError => _categoryError;

  String get currentCategoryName => _currentCategoryName;

  bool get isHomeLoading => _homeState == LoadState.loading;
  bool get isLatestLoading => _latestState == LoadState.loading;
  bool get isCategoryLoading => _categoryState == LoadState.loading;

  Future<void> loadHomeNews({bool forceRefresh = false}) async {
    // Cache 5 phút
    if (!forceRefresh &&
        _homeState == LoadState.success &&
        _lastHomeRefresh != null &&
        DateTime.now().difference(_lastHomeRefresh!).inMinutes < 5) {
      return;
    }

    _homeState = LoadState.loading;
    _homeError = '';
    notifyListeners();

    try {
      _homeArticles = await _service.fetchAllNews();
      _homeState = LoadState.success;
      _lastHomeRefresh = DateTime.now();
    } catch (e) {
      _homeState = LoadState.error;
      _homeError = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> loadLatestNews({bool forceRefresh = false}) async {
    _latestState = LoadState.loading;
    _latestError = '';
    notifyListeners();

    try {
      _latestArticles = await _service.fetchLatest(limit: 10);
      _latestState = LoadState.success;
    } catch (e) {
      _latestState = LoadState.error;
      _latestError = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> loadCategoryNews(String url, String categoryName) async {
    _currentCategoryName = categoryName;
    _categoryState = LoadState.loading;
    _categoryError = '';
    _categoryArticles = [];
    notifyListeners();

    try {
      _categoryArticles = await _service.fetchFeed(url, categoryName);
      _categoryState = LoadState.success;
    } catch (e) {
      _categoryState = LoadState.error;
      _categoryError = e.toString().replaceAll('Exception: ', '');
    }
    notifyListeners();
  }

  void clearCategoryArticles() {
    _categoryArticles = [];
    _categoryState = LoadState.idle;
    notifyListeners();
  }
}
