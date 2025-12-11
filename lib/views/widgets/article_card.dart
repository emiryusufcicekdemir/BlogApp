import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/article_model.dart';

class ArticleCard extends ConsumerWidget {
  final Article article;
  final String searchQuery;
  final Color highlightColor;

  const ArticleCard({
    super.key,
    required this.article,
    required this.searchQuery,
    required this.highlightColor,
  });

  @override
Widget build(BuildContext context, WidgetRef ref) {
  // isFavorite null ise false kaydet
  final bool isCurrentlyFavorite = article.isFavorite ?? false;

  return Card(
    color: Colors.white,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: ListTile(
      title: _buildHighlightedText(article.title),
      subtitle: _buildHighlightedText(article.content.split('\n').first),
      
      trailing:
          // Null kontrolünden geçmiş, nullable olmayan degisken 
          isCurrentlyFavorite 
              ? const Icon(Icons.star, color: Colors.amber, size: 20)
              : null,
    ),
  );
}

  Widget _buildHighlightedText(String text) {
    if (searchQuery.isEmpty) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    final lowerCaseText = text.toLowerCase();
    final lowerCaseQuery = searchQuery.toLowerCase();

    if (!lowerCaseText.contains(lowerCaseQuery)) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    final spans = <TextSpan>[];
    int start = 0;

    while (start < text.length) {
      final index = lowerCaseText.indexOf(lowerCaseQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + searchQuery.length),
          style: TextStyle(color: highlightColor, fontWeight: FontWeight.bold),
        ),
      );

      start = index + searchQuery.length;
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
