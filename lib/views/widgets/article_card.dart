import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/article_model.dart';
import '../../controllers/article_controller.dart';
import 'package:go_router/go_router.dart';

class ArticleCard extends ConsumerWidget {
  final Article article;
  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(article.title),
        subtitle: Text(
          article.content.length > 100
              ? '${article.content.substring(0, 100)}...'
              : article.content,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteDialog(context, ref),
        ),
        onTap: () => context.push('/detail/${article.id}'),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Silmek istiyor musun?'),
            content: Text('"${article.title}" adlı makale silinecek.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(articleProvider.notifier).deleteArticle(article.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
