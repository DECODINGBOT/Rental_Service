import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sharing_items/src/api_config.dart';

class LongUserSession {
  final int id;
  final String username;
  final DateTime createdAt;

  LongUserSession({
    required this.id,
    required this.username,
    required this.createdAt,
  });

  factory LongUserSession.fromJson(Map<String, dynamic> json){
    return LongUserSession(
        id: (json['id'] as num).toInt(),
        username: json['username'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class UserProfileResponse {
  final int id;
  final String username;
  final DateTime createdAt;
  final String? profileImageUrl;
  final String? address;
  final String? detailAddress;
  final String? phone;
  final String? bio;

  UserProfileResponse({
    required this.id,
    required this.username,
    required this.createdAt,
    this.profileImageUrl,
    this.address,
    this.detailAddress,
    this.phone,
    this.bio,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json){
    return UserProfileResponse(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      profileImageUrl: json['profileImageUrl'] as String?,
      address: json['address'] as String?,
      detailAddress: json['detailAddress'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?
    );
  }
}

class AuthService extends ChangeNotifier {
  LongUserSession? _session;
  LongUserSession? currentUser() => _session;
  bool get isLoggedIn => _session != null;

  /// 개인 와이파이 IP 주소에 맞춰 변경해서 사용
  /// ex) 'http://000.000.000.000:8080'
  final _baseUrl = ApiConfig.baseUrl;

  /// 로그인
  Future<void> signIn({
    required String username,
    required String password,
    required VoidCallback onSuccess,
    required Function(String err) onError,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/login');
      final res = await http.post(
        uri,
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if(res.statusCode >= 200 && res.statusCode < 300){
        // Response JSON: {id, username, createdAt}
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _session = LongUserSession.fromJson(data);
        notifyListeners();
        onSuccess();
        return;
      }
      onError(_extractError(res));
    }catch (e){
      onError(e.toString());
    }
  }

  /// 회원가입
  Future<void> signUp({
    required String username,
    required String password,
    required VoidCallback onSuccess,
    required Function(String err) onError,
  }) async {
    try {
      /// Android Emulator -> ex) 'http://0.0.0.0:0000'
      /// Device: PC와 같은 와이파이 IP -> ex) 'http://000.000.000.000:0000'
      /// 핸드폰으로 실행할 땐 개인 와이파이 주소로 변경 후 사용할 것.
      final uri = Uri.parse('$_baseUrl/api/auth/signup');
      final res = await http.post(
        uri,
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if(res.statusCode >= 200 && res.statusCode < 300){
        // Response JSON: {id, username, createdAt}
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _session = LongUserSession.fromJson(data);
        notifyListeners();
        onSuccess();
        return;
      }
      onError(_extractError(res));
    }catch (e){
      onError(e.toString());
    }
  }

  void signOut(){
    _session = null;
    notifyListeners();
  }

  /// 내 정보 조회
  Future<UserProfileResponse> fetchMyProfile() async {
    final s = _requireSession();
    final uri = Uri.parse('$_baseUrl/api/users/${s.id}');
    final res = await http.get(uri);

    if(res.statusCode >= 200 && res.statusCode < 300){
      return UserProfileResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception(_extractError(res));
  }

  // 내 정보 수정
  Future<UserProfileResponse> updateMyProfile({
    String? profileImageUrl,
    String? address,
    String? detailAddress,
    String? phone,
    String? bio,
  }) async {
    final s = _requireSession();
    final uri = Uri.parse('$_baseUrl/api/users/${s.id}');
    final res = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'profileImageUrl': profileImageUrl,
        'address': address,
        'detailAddress': detailAddress,
        'phone': phone,
        'bio': bio,
      }),
    );

    if(res.statusCode >= 200 && res.statusCode < 300){
      return UserProfileResponse.fromJson(jsonDecode(res.body));
    }
    throw Exception(_extractError(res));
  }

  Future<UserProfileResponse> uploadMyProfileImage(File file) async {
    final s = _requireSession();
    final uri = Uri.parse('$_baseUrl/api/users/${s.id}/profile-image');
    final req = http.MultipartRequest('POST', uri);
    req.files.add(await http.MultipartFile.fromPath('image', file.path));
    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if(res.statusCode >= 200 && res.statusCode < 300){
      return UserProfileResponse.fromJson(jsonDecode(res.body));
    }

    throw Exception(_extractError(res));
  }

  LongUserSession _requireSession(){
    final s = _session;
    if(s == null){
      throw Exception('로그인이 필요합니다.');
    }
    return s;
  }

  String _extractError(http.Response res){
    try{
      final body = jsonDecode(res.body);
      if(body is Map && body['message'] != null){
        return body['message'].toString();
      }
      return res.body.toString();
    }catch (_){
      return res.body.toString();
    }
  }
}
