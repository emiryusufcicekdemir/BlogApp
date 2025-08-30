import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'models/article_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive başlat
  await Hive.initFlutter();

  // Adapter kaydet
  Hive.registerAdapter(ArticleAdapter());

  // Kutu open
  await Hive.openBox<Article>('articlesBox');

  runApp(const ProviderScope(child: BlogApp()));
}
