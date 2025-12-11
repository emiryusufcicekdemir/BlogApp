import 'package:hive/hive.dart';
part 'article_model.g.dart';

@HiveType(typeId: 0)
class Article extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  DateTime? updatedAt;

  @HiveField(5)
  bool? isFavorite;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    bool? isFavorite,
    DateTime? updatedAt,
  }) :
   isFavorite = isFavorite ?? false,
   updatedAt = updatedAt ?? date;
}
