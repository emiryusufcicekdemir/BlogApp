import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/article_controller.dart';
import 'package:go_router/go_router.dart';

class CreateArticleView extends ConsumerStatefulWidget {
  const CreateArticleView({super.key});

  @override
  ConsumerState<CreateArticleView> createState() => _CreateArticleViewState();
}

class _CreateArticleViewState extends ConsumerState<CreateArticleView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(articleProvider.notifier)
          .addArticle(
            _titleController.text.trim(),
            _contentController.text.trim(),
          );
      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Makale Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Başlık'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'İçerik'),
                maxLines: 8,
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Zorunlu alan' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _submit, child: const Text('Kaydet')),
            ],
          ),
        ),
      ),
    );
  }
}
