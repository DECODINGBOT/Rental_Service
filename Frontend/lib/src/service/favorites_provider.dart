import 'package:flutter/foundation.dart';
import 'package:sharing_items/src/mock_items.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<int> _likedIds = {};
  bool isFavoriteByProductId(int id) => _likedIds.contains(id);
  List<int> get likedIds => _likedIds.toList(growable: false);

  void toggleByProductId(int id){
    if(_likedIds.contains(id)){
      _likedIds.remove(id);
    } else {
      _likedIds.add(id);
    }
    notifyListeners();
  }

  /*
  List<Map<String, dynamic>> get all => mockItems;

  List<Map<String, dynamic>> get liked =>
      mockItems.where((m) => (m['isLike'] as bool? ?? false)).toList();

  bool isFavoriteById(String id) => isLikedById(id);

  void toggleById(String id) {
    toggleLikeById(id);
    notifyListeners();
  }
   */
}
