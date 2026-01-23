import 'package:flutter/foundation.dart';
import 'package:sharing_items/src/service/product_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductService _service;
  ProductProvider(this._service);

  List<ProductListDto> _all = [];
  List<ProductListDto> get all => _all;

  List<ProductListDto> _my = [];
  List<ProductListDto> get my => _my;

  void setService(ProductService service){
    _service = service;
  }

  Future<void> refreshAll() async {
    _all = await _service.fetchAllLatest();
    notifyListeners();
  }

  Future<void> refreshMy(int ownerUserId) async {
    _my = await _service.fetchMyLatest(ownerUserId);
    notifyListeners();
  }

  Future<void> refreshAllAndMy(int ownerUserId) async {
    await Future.wait([refreshAll(), refreshMy(ownerUserId)]);
  }

  Future<List<ProductListDto>> fetchMyLatest(int ownerUserId) async {
    return _service.fetchMyLatest(ownerUserId);
  }
}
