import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/article_controller.dart';
import 'widgets/article_card.dart';
import '../models/article_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/rendering.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String searchQuery = '';
  bool showSearchBar = true;
  late final ScrollController scrollController = ScrollController();
  String sortOption = 'Önce Yeni';
  bool showOnlyFavorites = false;

  // MaterialColor kullanimi
  static const MaterialColor primaryColor = Colors.teal; // Ana aksan rengi
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white; // Kart rengi

  @override
  void initState() {
    super.initState();
    // Arama çubuğunu gizleme/gösterme
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (showSearchBar) {
          setState(() => showSearchBar = false);
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!showSearchBar) {
          setState(() => showSearchBar = true);
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  // Sıralama ve filtreleme
  List<Article> _getFilteredAndSortedArticles(List<Article> articles) {
    List<Article> sortedArticles = [...articles];

    // Sıralama
    switch (sortOption) {
      case 'Önce Yeni':
        sortedArticles.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Önce Eski':
        sortedArticles.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Düzenleme tarihi':
        sortedArticles.sort(
          (a, b) => (b.updatedAt ?? b.date).compareTo(a.updatedAt ?? a.date),
        );
        break;
      case 'İsim':
        sortedArticles.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    // Arama ve Favori filtrelemesi
    return sortedArticles.where((article) {
      final query = searchQuery.toLowerCase();
      final matchesSearch =
          article.title.toLowerCase().contains(query) ||
          article.content.toLowerCase().contains(query);
      final matchesFavorite =
          showOnlyFavorites ? article.isFavorite == true : true;
      return matchesSearch && matchesFavorite;
    }).toList();
  }

  // Silme Onay Dialog
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              title: Row(
                children: const [
                  Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  SizedBox(width: 10),
                  Text('Makaleyi Sil'),
                ],
              ),
              content: const Text(
                'Bu makaleyi kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('İptal', style: TextStyle(color: primaryColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Sil'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final articles = ref.watch(articleProvider);
    final filteredArticles = _getFilteredAndSortedArticles(articles);
    final isListEmpty = filteredArticles.isEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: false, // Baslik solda
        title: const Text(
          'Makalelerim',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w900, //  baslik boyutu
            fontSize: 24,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 1,
        // favori ve siralama
        actions: [_buildFavoriteButton(), _buildSortPopupMenu()],
      ),
      body: Column(
        children: [
          // searchbar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: showSearchBar ? 70 : 0,
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 20,
            ),
            child: showSearchBar ? _buildSearchBar() : null,
          ),
          // makale counter
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isListEmpty && showOnlyFavorites
                      ? 'Favorilere Eklenen Makale Yok'
                      : isListEmpty
                      ? 'Henüz Makale Yok'
                      : '${filteredArticles.length} Makale Listeleniyor',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // sorting bilgisi
                Text(
                  'Sırala: $sortOption',
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryColor.shade400, // ARTIK ÇALIŞIYOR
                  ),
                ),
              ],
            ),
          ),

          // makaleler
          Expanded(
            child:
                isListEmpty
                    ? _buildEmptyListMessage(context)
                    : ListView.builder(
                      controller: scrollController,
                      itemCount: filteredArticles.length,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];
                        return _buildArticleListItem(article, context);
                      },
                    ),
          ),
        ],
      ),
      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/create');
        },
        icon: const Icon(Icons.add_box_rounded),
        label: const Text('Yeni Makale'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // searchbar Widget
  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() => searchQuery = value);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: cardColor,
        hintText: 'Başlık veya içerikte ara...',
        hintStyle: TextStyle(color: Colors.grey.shade500),
        prefixIcon: const Icon(Icons.search, color: primaryColor),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        isDense: true,
      ),
    );
  }

  // fav button widget
  Widget _buildFavoriteButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          showOnlyFavorites = !showOnlyFavorites;
        });
      },
      icon: Icon(
        showOnlyFavorites ? Icons.star_rounded : Icons.star_border_rounded,
        color:
            showOnlyFavorites ? Colors.amber.shade700 : primaryColor.shade400,
        size: 28,
      ),
    );
  }

  // sorting PopupMenuButon widget
  Widget _buildSortPopupMenu() {
    return PopupMenuButton<String>(
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      offset: const Offset(0, 40),
      onSelected: (value) {
        setState(() => sortOption = value);
      },
      itemBuilder:
          (context) => [
            _buildPopupMenuItem(
              'Önce Yeni',
              Icons.fiber_new_rounded,
              primaryColor,
            ),
            _buildPopupMenuItem(
              'Önce Eski',
              Icons.history_toggle_off_rounded,
              Colors.orange,
            ),
            _buildPopupMenuItem(
              'Düzenleme tarihi',
              Icons.edit_calendar_rounded,
              Colors.blue,
            ),
            _buildPopupMenuItem(
              'İsim',
              Icons.sort_by_alpha_rounded,
              Colors.purple,
            ),
          ],
      icon: Icon(Icons.sort_rounded, color: primaryColor, size: 28),
    );
  }

  // PopupMenuItem build
  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }

  // makale listesi
  Widget _buildArticleListItem(Article article, BuildContext context) {
    return Dismissible(
      key: ValueKey(article.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        ref.read(articleProvider.notifier).deleteArticle(article.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${article.title} silindi.'),
            backgroundColor: primaryColor,
          ),
        );
      },
      child: InkWell(
        onTap: () {
          context.push('/detail/${article.id}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
          child: ArticleCard(
            article: article,
            searchQuery: searchQuery,
            highlightColor: primaryColor.shade400,
          ),
        ),
      ),
    );
  }

  // bos liste mesaji
  Widget _buildEmptyListMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              showOnlyFavorites
                  ? Icons.star_border
                  : Icons.library_books_rounded,
              size: 80,
              color: primaryColor.shade200,
            ),
            const SizedBox(height: 20),
            Text(
              showOnlyFavorites
                  ? 'Henüz favori makaleniz yok.'
                  : 'Oluşturulmuş makaleniz bulunmamaktadır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            if (!showOnlyFavorites)
              ElevatedButton.icon(
                onPressed: () => context.push('/create'),
                icon: const Icon(Icons.add_box_rounded),
                label: const Text('İlk Makaleyi Oluştur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
