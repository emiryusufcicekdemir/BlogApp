import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/article_controller.dart';

class ArticleDetailView extends ConsumerWidget {
  final String id;
  const ArticleDetailView({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.read(articleProvider.notifier).getById(id);

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detay')),
        body: const Center(child: Text('Makale bulunamadı')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: Padding(
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
              article.date.toLocal().toString(),
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
