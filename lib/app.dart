import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/home_view.dart';
import 'views/create_article_view.dart';
import 'views/article_detail_view.dart';
import 'models/article_model.dart';

class BlogApp extends StatelessWidget {
  const BlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: '/create',
          builder: (context, state) {
            // extra ile gönderilen article objesini cek
            final article = state.extra as Article?;
            return CreateArticleView(article: article);
          },
        ),
        GoRoute(
          path: '/detail/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ArticleDetailView(id: id);
          },
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Blog Uygulaması',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      routerConfig: router,
    );
  }
}
