import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionCreateDto {
  final int id;
  final int productId;
  final int renterUserId;
  final int ownerUserId;
  final String status;

  TransactionCreateDto({
    required this.id,
    required this.productId,
    required this.renterUserId,
    required this.ownerUserId,
    required this.status,
  });

  factory TransactionCreateDto.fromJson(Map<String, dynamic> j) {
    return TransactionCreateDto(
      id: (j['id'] as num).toInt(),
      productId: (j['productId'] as num).toInt(),
      renterUserId: (j['renterUserId'] as num).toInt(),
      ownerUserId: (j['ownerUserId'] as num).toInt(),
      status: (j['status'] ?? '').toString(),
    );
  }
}

class TransactionResponseDto {
  final int id;
  final int productId;
  final int renterUserId;
  final int ownerUserId;
  final String status;

  TransactionResponseDto({
    required this.id,
    required this.productId,
    required this.renterUserId,
    required this.ownerUserId,
    required this.status,
  });

  factory TransactionResponseDto.fromJson(Map<String, dynamic> j) {
    return TransactionResponseDto(
      id: (j['id'] as num).toInt(),
      productId: (j['productId'] as num).toInt(),
      renterUserId: (j['renterUserId'] as num).toInt(),
      ownerUserId: (j['ownerUserId'] as num).toInt(),
      status: (j['status'] ?? '').toString(),
    );
  }
}

class TransactionService {
  final http.Client client;
  final String baseUrl;

  TransactionService(this.client, {required this.baseUrl});

  Future<TransactionCreateDto> create({
    required int productId,
    required int renterUserId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/transactions');
    final res = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': productId,
        'renterUserId': renterUserId,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('transaction create failed: ${res.statusCode} ${res.body}');
    }

    return TransactionCreateDto.fromJson(jsonDecode(res.body));
  }

  Future<TransactionResponseDto> startRental({
    required int transactionId,
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    // 백엔드가 @RequestParam LocalDateTime 이라서 ISO 문자열로 넘기면 가장 깔끔해
    final startIso = startAt.toIso8601String();
    final endIso = endAt.toIso8601String();

    final uri = Uri.parse('$baseUrl/api/transactions/$transactionId/start')
        .replace(queryParameters: {
      'startAt': startIso,
      'endAt': endIso,
    });

    final res = await client.post(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('startRental failed: ${res.statusCode} ${res.body}');
    }

    return TransactionResponseDto.fromJson(jsonDecode(res.body));
  }

  // transaction_service.dart에 추가 (class TransactionService 안)

  Future<List<TransactionResponseDto>> listByRenter(int renterUserId) async {
    final uri = Uri.parse('$baseUrl/api/transactions/renter/$renterUserId');
    final res = await client.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('listByRenter failed: ${res.statusCode} ${res.body}');
    }

    final arr = jsonDecode(res.body) as List;
    return arr
        .map((e) => TransactionResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TransactionResponseDto>> listByOwner(int ownerUserId) async {
    final uri = Uri.parse('$baseUrl/api/transactions/owner/$ownerUserId');
    final res = await client.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('listByOwner failed: ${res.statusCode} ${res.body}');
    }

    final arr = jsonDecode(res.body) as List;
    return arr
        .map((e) => TransactionResponseDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionResponseDto> accept({
    required int transactionId,
    required int ownerUserId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/transactions/$transactionId/accept');
    final res = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ownerUserId': ownerUserId}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('accept failed: ${res.statusCode} ${res.body}');
    }

    return TransactionResponseDto.fromJson(jsonDecode(res.body));
  }
}
