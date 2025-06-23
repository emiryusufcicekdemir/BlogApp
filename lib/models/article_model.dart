// models/article_model.dart
import 'package:hive/hive.dart';
part 'article_model.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime date;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });
}
