import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/article_controller.dart';
import 'package:go_router/go_router.dart';

class ArticleDetailView extends ConsumerWidget {
  final String id;
  const ArticleDetailView({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleController = ref.read(articleProvider.notifier);
    final article = articleController.getById(id);

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detay')),
        body: const Center(child: Text('Makale bulunamadı')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/create', extra: article);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Silmek istediğinize emin misiniz?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sil')),
                  ],
                ),
              );
              if (confirm == true) {
                articleController.deleteArticle(id);
                context.pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMM yyyy – HH:mm').format(article.date.toLocal()),
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            Text(article.content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}