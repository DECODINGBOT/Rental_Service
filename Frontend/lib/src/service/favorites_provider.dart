import 'package:flutter/foundation.dart';
import 'package:sharing_items/src/mock_items.dart';

class FavoritesProvider with ChangeNotifier {
  List<Map<String, dynamic>> get all => mockItems;

  List<Map<String, dynamic>> get liked =>
      mockItems.where((m) => (m['isLike'] as bool? ?? false)).toList();

  bool isFavoriteById(String id) => isLikedById(id);

  void toggleById(String id) {
    toggleLikeById(id);
    notifyListeners();
  }
}
