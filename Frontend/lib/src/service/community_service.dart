import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sharing_items/src/api_config.dart';

class CommunityListItemDto{
  final int id;
  final String title;
  final String preview;
  final String username;
  final String? profileImageUrl;
  final int likeCount;
  final int commentCount;
  final String createdAt;

  CommunityListItemDto({
    required this.id,
    required this.title,
    required this.preview,
    required this.username,
    required this.profileImageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt
  });

  factory CommunityListItemDto.fromJson(Map<String, dynamic> json){
    return CommunityListItemDto(
        id: (json['id'] as num).toInt(),
        title: (json['title'] ?? '') as String,
        preview: (json['preview'] ?? '') as String,
        username: (json['username'] ?? '') as String,
        profileImageUrl: json['profileImageUrl'] as String?,
        likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
        commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
        createdAt: (json['createdAt'] ?? '') as String
    );
  }
}

class CommentDto{
  final int id;
  final String username;
  final String? profileImageUrl;
  final String content;
  final String createdAt;

  CommentDto({
    required this.id,
    required this.username,
    required this.profileImageUrl,
    required this.content,
    required this.createdAt
  });

  factory CommentDto.fromJson(Map<String, dynamic> json){
    return CommentDto(
        id: (json['id'] as num).toInt(),
        username: (json['username'] ?? '') as String,
        profileImageUrl: json['profileImageUrl'] as String?,
        content: (json['content'] ?? '') as String,
        createdAt: (json['createdAt'] ?? '') as String
    );
  }
}

class CommunityDetailDto{
  final int id;
  final String title;
  final String content;
  final String username;
  final String? profileImageUrl;
  final int likeCount;
  final int commentCount;
  final String createdAt;
  final String updatedAt;
  final bool liked;
  final List<CommentDto> comments;
  final List<String> imageUrls;

  CommunityDetailDto({
    required this.id,
    required this.title,
    required this.content,
    required this.username,
    required this.profileImageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    required this.liked,
    required this.comments,
    required this.imageUrls
  });

  factory CommunityDetailDto.fromJson(Map<String, dynamic> json){
    final commentsJson = (json['comments'] as List?) ?? const [];
    final imageUrlsJson = (json['imageUrls'] as List?) ?? const [];

    return CommunityDetailDto(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      username: (json['username'] ?? '') as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] ?? '') as String,
      updatedAt: (json['updatedAt'] ?? '') as String,
      liked: (json['liked'] as bool?) ?? false,
      comments: commentsJson
          .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrls: imageUrlsJson.map((e) => e.toString()).toList(),
    );
  }
}

class LikeToggleResponse{
  final bool liked;
  final int likeCount;

  LikeToggleResponse({
    required this.liked,
    required this.likeCount
  });

  factory LikeToggleResponse.fromJson(Map<String, dynamic> json){
    return LikeToggleResponse(
      liked: (json['liked'] as bool?) ?? false,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class CommunityService{
  final _baseUrl = ApiConfig.baseUrl;

  Future<List<CommunityListItemDto>> fetchBoards() async {
    final uri = Uri.parse('$_baseUrl/api/boards');
    final res = await http.get(
      uri,
      headers: {'Accept': "application/json"}
    );

    if(res.statusCode < 200 || res.statusCode >= 300){
      throw Exception('fetchBoards failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if(decoded is! List){
      throw Exception('Expected List response but got: ${decoded.runtimeType}');
    }

    return decoded
        .map((e) => CommunityListItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CommunityDetailDto> fetchBoardDetail({
    required int boardId,
    int? userId,
  }) async {
    final qp = <String, String>{};
    if(userId != null) qp['userId'] = userId.toString();

    final uri = Uri.parse('$_baseUrl/api/boards/$boardId').replace(queryParameters: qp);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if(res.statusCode < 200 || res.statusCode >= 300){
      throw Exception('fetchBoardDetail failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if(decoded is! Map<String, dynamic>){
      throw Exception('Expected Map response but got: ${decoded.runtimeType}');
    }

    return CommunityDetailDto.fromJson(decoded);
  }

  Future<CommunityDetailDto> createBoard({
    required String title,
    required String content,
    required int userId,
    List<File> images = const [],
  }) async {
    final uri = Uri.parse('$_baseUrl/api/boards');
    final req = http.MultipartRequest('POST', uri);
    final requestJson = jsonEncode({
      'title': title,
      'content': content,
      'userId': userId,
    });

    req.files.add(
      http.MultipartFile.fromString(
        'request',
        requestJson,
        contentType: MediaType('application', 'json'),
      ),
    );

    for(final f in images){
      final fileName = f.path.split(Platform.pathSeparator).last;
      req.files.add(
        await http.MultipartFile.fromPath(
          'images',
          f.path,
          filename: fileName,
        ),
      );
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if(res.statusCode < 200 || res.statusCode >= 300){
      throw Exception('createBoard failed: ${res.statusCode} ${res.body}');
    }

    return CommunityDetailDto.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<CommentDto> addComment({
    required int boardId,
    required int userId,
    required String content,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/boards/$boardId/comments');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'content': content,
      }),
    );

    if(res.statusCode < 200 || res.statusCode >= 300){
      throw Exception('addComment failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if(decoded is! Map<String, dynamic>){
      throw Exception('Expected Map response but got: ${decoded.runtimeType}');
    }

    return CommentDto.fromJson(decoded);
  }

  Future<LikeToggleResponse> toggleLike({
    required int boardId,
    required int userId
  }) async {
    final uri = Uri.parse('$_baseUrl/api/boards/$boardId/likes/toggle');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    if(res.statusCode < 200 || res.statusCode >= 300){
      throw Exception('toggleLike failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if(decoded is! Map<String, dynamic>){
      throw Exception('Expected Map response but got: ${decoded.runtimeType}');
    }

    return LikeToggleResponse.fromJson(decoded);
  }
}