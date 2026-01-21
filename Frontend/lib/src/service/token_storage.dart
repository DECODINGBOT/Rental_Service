import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StoredUser{
  final int id;
  final String username;
  final String createdAtIso;

  StoredUser({
    required this.id,
    required this.username,
    required this.createdAtIso,
  });
}

class TokenStorage{
  static const _storage = FlutterSecureStorage();
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUserId = 'user_id';
  static const _kUsername = 'username';
  static const _kCreatedAt = 'created_at';

  Future<void> saveLogin({
    required String accessToken,
    required String refreshToken,
    required int userId,
    required String username,
    required String createdAtIso,
  }) async {
    await _storage.write(key: _kAccess, value: accessToken);
    await _storage.write(key: _kRefresh, value: refreshToken);
    await _storage.write(key: _kUserId, value: userId.toString());
    await _storage.write(key: _kUsername, value: username);
    await _storage.write(key: _kCreatedAt, value: createdAtIso);
  }

  Future<String?> readAccessToken() => _storage.read(key: _kAccess);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _kAccess, value: accessToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUsername);
    await _storage.delete(key: _kCreatedAt);
  }

  Future<StoredUser?> readUser() async {
    final idStr = await _storage.read(key: _kUserId);
    final username = await _storage.read(key: _kUsername);
    final createdAt = await _storage.read(key: _kCreatedAt);

    if(idStr == null || username == null || createdAt == null){
      return null;
    }

    final id = int.tryParse(idStr);
    if(id == null){
      return null;
    }

    return StoredUser(
      id: id,
      username: username,
      createdAtIso: createdAt
    );
  }
}