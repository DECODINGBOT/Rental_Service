import 'package:http/http.dart' as http;
import 'package:sharing_items/src/service/auth_client.dart';
import 'package:sharing_items/src/service/token_storage.dart';

class ApiClient{
  ApiClient._();
  static final TokenStorage storage = TokenStorage();
  static final http.Client raw = http.Client();
  static final http.Client authed = AuthClient(raw, storage);
}