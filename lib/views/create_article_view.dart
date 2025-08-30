import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/article_controller.dart';
import 'package:go_router/go_router.dart';
import '../models/article_model.dart';

class CreateArticleView extends ConsumerStatefulWidget {
  final Article? article; // Düzenleme için optional
  const CreateArticleView({super.key, this.article});

  @override
  ConsumerState<CreateArticleView> createState() => _CreateArticleViewState();
}

class _CreateArticleViewState extends ConsumerState<CreateArticleView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController = TextEditingController(
      text: widget.article?.content ?? '',
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(articleProvider.notifier);
      if (widget.article != null) {
        notifier.updateArticle(
          widget.article!.id,
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
      } else {
        notifier.addArticle(
          _titleController.text.trim(),
          _contentController.text.trim(),
        );
      }
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
    final isEditing = widget.article != null;
    final softColor = Colors.teal[300]; // Soft, gözü yormayan ton
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isEditing ? 'Makale Düzenle' : 'Yeni Makale'),
        backgroundColor: softColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Başlık',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Zorunlu alan'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'İçerik',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.article),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 10,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Zorunlu alan'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: softColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(isEditing ? 'Güncelle' : 'Kaydet'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
