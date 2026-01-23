import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/const/Colors.dart';
import 'package:sharing_items/src/custom/item_info.dart';
import 'package:sharing_items/src/service/favorites_provider.dart';
import 'package:sharing_items/screens/product_detail_screen.dart';
import 'package:sharing_items/src/service/product_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final products = context.watch<ProductProvider>().all;
    //final liked = fav.liked;
    final likedProducts = products.where((p) => fav.isFavoriteByProductId(p.id)).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(61),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          //centerTitle: true,
          titleSpacing: 16,
          title: Row(
            children: [
              const Icon(Icons.star, color: Colors.black, size: 32),
              const SizedBox(width: 8),
              const Text(
                '즐겨찾기',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.black),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: likedProducts.isEmpty
            ? const Center(child: Text('즐겨찾기한 항목이 없습니다.'))
            : ListView.separated(
                itemCount: likedProducts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  //final m = liked[index];
                  //final id = m['id'] as String;
                  final p = likedProducts[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(productId: p.id),
                        ),
                      );
                    },
                    child: ItemInfo(
                      key: ValueKey(p.id),
                      category: p.category,
                      title: p.title,
                      location: p.location,
                      price: p.pricePerDay,
                      thumbnailUrl: p.thumbnailUrl,
                      isLike: fav.isFavoriteByProductId(p.id),
                      onLikeChanged: (_) {
                        context
                            .read<FavoritesProvider>()
                            .toggleByProductId(p.id);
                      },
                      /*
                      key: ValueKey(id),
                      category: m['category'] as String,
                      title: m['title'] as String,
                      location: m['location'] as String,
                      price: m['price'] as int,
                      isLike: fav.isFavoriteById(id),
                      onLikeChanged: (_) {
                        context.read<FavoritesProvider>().toggleById(id);
                      },
                       */
                    ),
                  );
                },
              ),
      ),
    );
  }
}
