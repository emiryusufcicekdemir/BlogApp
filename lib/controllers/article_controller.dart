import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/article_model.dart';
import 'package:uuid/uuid.dart';

class ArticleController extends StateNotifier<List<Article>> {
  ArticleController() : super([]) {
    _loadArticles();
  }
  final Box<Article> _box = Hive.box<Article>('articlesBox');

  // Hive tüm makaleleri StateNotifier stateine yükle
  void _loadArticles() {
    state = _box.values.toList();
  }

  // Makale Ekleme
  void addArticle(String title, String content) {
    final newArticle = Article(
      id: const Uuid().v4(),
      title: title,
      content: content,
      date: DateTime.now(),
      // isFavorite varsayılan olarak Article modelinde zaten false ayarlandı.
    );
    _box.put(newArticle.id, newArticle);
    state = [...state, newArticle]; // State'e ekle
  }

  // Makale Silme
  void deleteArticle(String id) {
    _box.delete(id);
    state = state.where((article) => article.id != id).toList();
  }

  //  Makale update
  void updateArticle(String id, String title, String content) {
    final article = _box.get(id);
    if (article != null) {
      article.title = title;
      article.content = content;
      article.updatedAt = DateTime.now();

      article.save(); // Hive update

      // State update
      state = state.map((a) => a.id == id ? article : a).toList();
    }
  }

  // Favori Durumu Değiştirme
  void toggleFavorite(String id) {
    final article = _box.get(id);
    if (article != null) {
      final currentStatus = article.isFavorite ?? false;
      article.isFavorite = !currentStatus;

      article.updatedAt = DateTime.now();

      article.save(); // Hive'ı güncelle

      // Statei güncelleme
      state = state.map((a) => a.id == id ? article : a).toList();
    }
  }
}

// provider global
final articleProvider = StateNotifierProvider<ArticleController, List<Article>>(
  (ref) => ArticleController(),
);
