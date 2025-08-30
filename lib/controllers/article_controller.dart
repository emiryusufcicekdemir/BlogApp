import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/article_model.dart';
import 'package:uuid/uuid.dart';

class ArticleController extends StateNotifier<List<Article>> {
  ArticleController() : super([]) {
    _loadArticles();
  }

  final Box<Article> _box = Hive.box<Article>('articlesBox');

  void _loadArticles() {
    state = _box.values.toList();
  }

  void addArticle(String title, String content) {
    final newArticle = Article(
      id: const Uuid().v4(),
      title: title,
      content: content,
      date: DateTime.now(),
    );
    _box.put(newArticle.id, newArticle);
    state = [...state, newArticle];
  }

  void deleteArticle(String id) {
    _box.delete(id);
    state = state.where((article) => article.id != id).toList();
  }

  Article? getById(String id) {
    return _box.get(id);
  }

  void updateArticle(String id, String title, String content) {
    final article = _box.get(id);
    if (article != null) {
      article.title = title;
      article.content = content;
      article.save();
      _loadArticles(); // state güncellemesi
    }
  }
}

// provider global
final articleProvider = StateNotifierProvider<ArticleController, List<Article>>(
  (ref) => ArticleController(),
);
