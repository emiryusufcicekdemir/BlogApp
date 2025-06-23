// views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/article_controller.dart';
import 'widgets/article_card.dart';
import 'package:go_router/go_router.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Makaleler')),
      body:
          articles.isEmpty
              ? const Center(child: Text('Henüz makale yok'))
              : ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return ArticleCard(article: article);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
