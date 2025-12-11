import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import '../controllers/article_controller.dart';
import 'package:go_router/go_router.dart';
import '../models/article_model.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

// Renk Paleti
const MaterialColor primaryColor = Colors.teal;
const Color backgroundColor = Color(0xFFF5F7FA);

// PDF Fonksiyonu (Değişmedi)
Future<Uint8List> generatePdf(Article article) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                article.title,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              // tarih formatı
              pw.Text(
                'Oluşturulma Tarihi: ${DateFormat('dd MMM yyyy – HH:mm').format(article.date.toLocal())}',
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColor.fromInt(0xFF888888),
                ),
              ),
              // güncelleme tarihi
              if (article.updatedAt != null) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  'Son Düzenleme: ${DateFormat('dd MMM yyyy – HH:mm').format(article.updatedAt!.toLocal())}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColor.fromInt(0xFF888888),
                  ),
                ),
              ],
              pw.Divider(height: 24),
              pw.Text(article.content, style: pw.TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}

class ArticleDetailView extends ConsumerWidget {
  final String id;
  const ArticleDetailView({super.key, required this.id});

  // ✨ GÜNCELLENMİŞ Silme Onay Dialog'u
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              // Modern, yuvarlak köşe stili
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              titlePadding: const EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: 0,
              ),
              contentPadding: const EdgeInsets.only(
                top: 10,
                left: 24,
                right: 24,
                bottom: 0,
              ),
              actionsPadding: const EdgeInsets.all(16),

              title: Row(
                children: const [
                  // Uyarı ikonu ve renk vurgusu
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 30,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Silme İşlemi Onayı',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text(
                'Bu makaleyi **kalıcı olarak** silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),

              actions: [
                // İptal Butonu (Metin rengi Teal)
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: primaryColor, fontSize: 16),
                  ),
                ),
                // Sil Butonu (Kırmızı Arka Plan)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600, // Kırmızı vurgu
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Sil', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articleProvider);
    Article? article = articles.firstWhereOrNull((a) => a.id == id);

    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detay')),
        body: const Center(child: Text('Makale bulunamadı')),
      );
    }

    final articleController = ref.read(articleProvider.notifier);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: backgroundColor,
      // Sabit, standart AppBar
      appBar: AppBar(
        title: Text(
          article.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: primaryColor,
        elevation: 4,
        actions: [
          _buildFavoriteButton(ref, article),
          _buildPdfButton(article),
          _buildEditButton(context, article),
          _buildDeleteButton(context, ref, articleController, article.id),
          const SizedBox(width: 8),
        ],
      ),
      // Tekrar SingleChildScrollView ile içerik
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık kaldırıldı (AppBar'da gösteriliyor)

            // Tarih Bilgileri Kutusu
            _buildDateInfo(article),
            const SizedBox(height: 20),

            // İçerik Alanı
            Text(
              article.content,
              style: textTheme.bodyLarge!.copyWith(
                fontSize: 17,
                height: 1.6, // Okunabilirliği artırır
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tarih Bilgileri Widget (Değişmedi)
  Widget _buildDateInfo(Article article) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(article.date.toLocal());
    final formattedUpdated =
        article.updatedAt != null
            ? dateFormat.format(article.updatedAt!.toLocal())
            : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.shade50, // Çok açık yeşil arka plan
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            icon: Icons.access_time_filled,
            label: 'Oluşturulma:',
            value: formattedDate,
            color: primaryColor,
          ),
          if (formattedUpdated != null) ...[
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.edit_calendar,
              label: 'Son Düzenleme:',
              value: formattedUpdated,
              color: primaryColor.shade400,
            ),
          ],
        ],
      ),
    );
  }

  // Bilgi Satırı (Değişmedi)
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // eylem butonlari
  Widget _buildFavoriteButton(WidgetRef ref, Article article) {
    final bool isCurrentlyFavorite = article.isFavorite ?? false;
    return IconButton(
      icon: Icon(
        isCurrentlyFavorite ? Icons.star_rounded : Icons.star_border_rounded,
        color: isCurrentlyFavorite ? Colors.amberAccent : Colors.white,
      ),
      onPressed: () {
        ref.read(articleProvider.notifier).toggleFavorite(article.id);
      },
    );
  }

  Widget _buildPdfButton(Article article) {
    return IconButton(
      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
      onPressed: () async {
        final pdfBytes = await generatePdf(article);
        await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
      },
    );
  }

  Widget _buildEditButton(BuildContext context, Article article) {
    return IconButton(
      icon: const Icon(Icons.edit_rounded, color: Colors.white),
      onPressed: () {
        context.push('/create', extra: article);
      },
    );
  }

  Widget _buildDeleteButton(
    BuildContext context,
    WidgetRef ref,
    ArticleController articleController,
    String id,
  ) {
    return IconButton(
      icon: const Icon(Icons.delete_forever_rounded, color: Colors.white),
      onPressed: () async {
        final confirm = await _showDeleteConfirmation(context);
        if (confirm) {
          articleController.deleteArticle(id);
          context.pop();
        }
      },
    );
  }
}

// FirstWhereOrNull icin extension
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
