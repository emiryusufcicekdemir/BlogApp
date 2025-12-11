import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/article_controller.dart';
import 'package:go_router/go_router.dart';
import '../models/article_model.dart';

class CreateArticleView extends ConsumerStatefulWidget {
  final Article? article;
  const CreateArticleView({super.key, this.article});

  @override
  ConsumerState<CreateArticleView> createState() => _CreateArticleViewState();
}

class _CreateArticleViewState extends ConsumerState<CreateArticleView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  static const Color primaryColor = Colors.teal;
  static const Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController = TextEditingController(
      text: widget.article?.content ?? '',
    );
  }

  void _submit() {
    // icerik kontrolu
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Makale başlığı boş bırakılamaz.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Makale içeriği boş bırakılamaz.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.article != null;

    return Scaffold(
      backgroundColor: cardColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? 'Makale Düzenle' : 'Yeni Makale Oluştur',
          style: const TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // baslik
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12.0,
              ),
              child: _buildTitleField(
                controller: _titleController,
                isEditing: isEditing,
              ),
            ),

            // icerik
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildContentField(controller: _contentController),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _submit,
        icon: Icon(isEditing ? Icons.save_rounded : Icons.add_circle_outline),
        label: Text(isEditing ? 'Güncelle' : 'Kaydet'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // baslik alani
  Widget _buildTitleField({
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: isEditing ? 'Makale Başlığı' : 'Başlık',
        hintStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade400,
        ),
        // sınırları kaldır
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      maxLines: 1,
    );
  }

  // icerik alani
  Widget _buildContentField({required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Makale içeriğinizi buraya yazın...',
        hintStyle: TextStyle(
          fontSize: 17,
          color: Colors.grey.shade500,
          height: 1.6,
        ),
        // sınırları kaldırma
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: 17, color: Colors.grey.shade800, height: 1.6),
      keyboardType: TextInputType.multiline,
      maxLines: null, // Sayfanın tümünü kullan
    );
  }
}
