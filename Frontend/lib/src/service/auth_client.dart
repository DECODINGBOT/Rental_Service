import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sharing_items/src/api_config.dart';
import 'package:sharing_items/src/service/token_storage.dart';

class AuthClient extends http.BaseClient{
  final http.Client _inner;
  final TokenStorage _storage;

  AuthClient(this._inner, this._storage);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    /// 1) accessToken 첨부
    final access = await _storage.readAccessToken();
    if(access != null && access.isNotEmpty){
      request.headers['Authorization'] = 'Bearer $access';
    }
    if(request is! http.Request){
      return _inner.send(request);
    }

    /// 원본 Request 복제
    final original = _cloneRequest(request);
    final res = await _inner.send(request);
    /// 401이면 refresh 후 1회 재시도
    if(res.statusCode != 401){
      return res;
    }

    final refreshed = await _tryRefreshAccessToken();
    if(!refreshed){
      /// refresh 실패면 그래도 401 반환
      return res;
    }

    final newAccess = await _storage.readAccessToken();
    final retry = _cloneRequest(original);
    if(newAccess != null && newAccess.isNotEmpty){
      retry.headers['Authorization'] = 'Bearer $newAccess';
    }
    return _inner.send(retry);
  }

  http.Request _cloneRequest(http.Request r){
    final nr = http.Request(r.method, r.url);
    nr.headers.addAll(r.headers);
    nr.bodyBytes = r.bodyBytes;
    nr.followRedirects = r.followRedirects;
    nr.maxRedirects = r.maxRedirects;
    nr.persistentConnection = r.persistentConnection;
    return nr;
  }

  Future<bool> _tryRefreshAccessToken() async {
    final refresh = await _storage.readRefreshToken();
    if(refresh == null || refresh.isEmpty){
      return false;
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh');
    final res = await _inner.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refresh})
    );
    if(res.statusCode < 200 || res.statusCode >= 300){
      /// refreshToken 만료/삭제된 경우 => 저장소 초기화
      await _storage.clear();
      return false;
    }

    final decoded = jsonDecode(res.body);
    if(decoded is! Map<String, dynamic>){
      return false;
    }

    final newAccess = decoded['accessToken']?.toString();
    if(newAccess == null || newAccess.isEmpty){
      return false;
    }
    await _storage.saveAccessToken(newAccess);
    return true;
  }
}