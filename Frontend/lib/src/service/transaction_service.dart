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
}
