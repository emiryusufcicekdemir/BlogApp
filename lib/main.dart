import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'models/article_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ArticleAdapter());
  }

  await runZonedGuarded(
    () async {
      await Hive.openBox<Article>('articlesBox');

      runApp(const ProviderScope(child: BlogApp()));
    },
    (error, stack) {
      debugPrint("Fatal Error: $error");
      debugPrint(stack.toString());
    },
  );
}
