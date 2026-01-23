import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sharing_items/src/api_config.dart';

class ProductDetailDto {
  final int id;
  final String title;
  final String description;
  final String category;
  final int pricePerDay;
  final int deposit;
  final String location;
  final String? thumbnailUrl;
  final int ownerUserId;
  final String ownerUsername;
  final String? ownerProfileImageUrl;
  final String createdAt;

  ProductDetailDto({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.pricePerDay,
    required this.deposit,
    required this.location,
    required this.thumbnailUrl,
    required this.ownerUserId,
    required this.ownerUsername,
    required this.ownerProfileImageUrl,
    required this.createdAt,
  });

  factory ProductDetailDto.fromJson(Map<String, dynamic> json) {
    return ProductDetailDto(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      pricePerDay: (json['pricePerDay'] as num?)?.toInt() ?? 0,
      deposit: (json['deposit'] as num?)?.toInt() ?? 0,
      location: (json['location'] ?? '') as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      ownerUserId: (json['ownerUserId'] as num?)?.toInt() ?? 0,
      ownerUsername: (json['ownerUsername'] ?? '') as String,
      ownerProfileImageUrl: json['ownerProfileImageUrl'] as String?,
      createdAt: (json['createdAt'] ?? '') as String,
    );
  }
}

extension ProductServiceDetail on ProductService {
  Future<ProductDetailDto> fetchDetail(int productId) async {
    final uri = Uri.parse('$_baseUrl/api/products/$productId');
    final res = await _client.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('fetchDetail failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Expected Map but got ${decoded.runtimeType}');
    }

    return ProductDetailDto.fromJson(decoded);
  }
}


class ProductListDto{
  final int id;
  final String title;
  final String category;
  final int pricePerDay;
  final int deposit;
  final String location;
  final String? thumbnailUrl;
  final int ownerUserId;
  final String ownerUsername;
  final String? ownerProfileImageUrl;
  final String createdAt;

  ProductListDto({
    required this.id,
    required this.title,
    required this.category,
    required this.pricePerDay,
    required this.deposit,
    required this.location,
    required this.thumbnailUrl,
    required this.ownerUserId,
    required this.ownerUsername,
    required this.ownerProfileImageUrl,
    required this.createdAt,
  });

  factory ProductListDto.fromJson(Map<String, dynamic> json) {
    return ProductListDto(
      id: (json['id'] as num).toInt(),
      title: (json['title'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      pricePerDay: (json['pricePerDay'] as num?)?.toInt() ?? 0,
      deposit: (json['deposit'] as num?)?.toInt() ?? 0,
      location: (json['location'] ?? '') as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      ownerUserId: (json['ownerUserId'] as num?)?.toInt() ?? 0,
      ownerUsername: (json['ownerUsername'] ?? '') as String,
      ownerProfileImageUrl: json['ownerProfileImageUrl'] as String?,
      createdAt: (json['createdAt'] ?? '') as String,
    );
  }
}

class ProductCreateResult {
  final int id;
  final String? thumbnailUrl;

  ProductCreateResult({required this.id, required this.thumbnailUrl});
}

class ProductService {
  final String _baseUrl = ApiConfig.baseUrl;
  final http.Client _client; // 반드시 AuthClient로 넣어주기

  ProductService(this._client);

  Future<List<ProductListDto>> fetchAllLatest() async {
    final uri = Uri.parse('$_baseUrl/api/products');
    final res = await _client.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('fetchAllLatest failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Expected List but got ${decoded.runtimeType}');
    }

    return decoded
        .map((e) => ProductListDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductListDto>> fetchMyLatest(int ownerUserId) async {
    final uri = Uri.parse('$_baseUrl/api/products/my')
        .replace(queryParameters: {'ownerUserId': ownerUserId.toString()});

    final res = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('fetchMyLatest failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! List) {
      throw Exception('Expected List but got ${decoded.runtimeType}');
    }

    return decoded
        .map((e) => ProductListDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProductCreateResult> createWithThumbnail({
    required String title,
    required String description,
    required String category,
    required int pricePerDay,
    required int deposit,
    required String location,
    required int ownerUserId,
    required String accessToken,
    File? thumbnailFile,
  }) async {
    // 1) create product (JSON)
    final createUri = Uri.parse('$_baseUrl/api/products');
    final createRes = await _client.post(
      createUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'description': description,
        'category': category,
        'pricePerDay': pricePerDay,
        'deposit': deposit,
        'location': location,
        'thumbnailUrl': null,
        'ownerUserId': ownerUserId,
      }),
    );

    if (createRes.statusCode < 200 || createRes.statusCode >= 300) {
      throw Exception('create product failed: ${createRes.statusCode} ${createRes.body}');
    }

    final created = jsonDecode(createRes.body) as Map<String, dynamic>;
    final productId = (created['id'] as num).toInt();

    // 2) upload thumbnail (optional)
    String? uploadedUrl;
    if (thumbnailFile != null) {
      uploadedUrl = await uploadThumbnail(
        productId: productId,
        file: thumbnailFile,
        accessToken: accessToken,
      );
    }
    return ProductCreateResult(id: productId, thumbnailUrl: uploadedUrl);
  }

  Future<String> uploadThumbnail({
    required int productId,
    required File file,
    required String accessToken, // 핵심: Authorization 수동 주입
  }) async {
    final uri = Uri.parse('$_baseUrl/api/products/$productId/thumbnail');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $accessToken';
    req.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('uploadThumbnail failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final url = decoded['thumbnailUrl']?.toString();
    if (url == null || url.isEmpty) {
      throw Exception('thumbnailUrl missing in response');
    }
    return url;
  }

  Future<ProductDetailDto> fetchDetail(int id) async {
    final uri = Uri.parse('$_baseUrl/api/products/$id');
    final res = await _client.get(uri, headers: {'Accept': 'application/json'});

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('fetchDetail failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductDetailDto.fromJson(decoded);
  }

}

