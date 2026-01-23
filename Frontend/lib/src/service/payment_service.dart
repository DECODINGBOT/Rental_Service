import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentPrepareDto {
  final String orderId;
  final int amount;

  PaymentPrepareDto({required this.orderId, required this.amount});

  factory PaymentPrepareDto.fromJson(Map<String, dynamic> j) {
    return PaymentPrepareDto(
      orderId: j['orderId'] as String,
      amount: (j['amount'] as num).toInt(),
    );
  }
}

class PaymentConfirmDto {
  final String orderId;
  final String paymentKey;
  final int amount;
  final String status;

  PaymentConfirmDto({
    required this.orderId,
    required this.paymentKey,
    required this.amount,
    required this.status,
  });

  factory PaymentConfirmDto.fromJson(Map<String, dynamic> j) {
    return PaymentConfirmDto(
      orderId: j['orderId'] as String,
      paymentKey: (j['paymentKey'] ?? '') as String,
      amount: (j['amount'] as num).toInt(),
      status: (j['status'] ?? '') as String,
    );
  }
}

class PaymentService {
  final http.Client client;
  final String baseUrl;

  PaymentService(this.client, {required this.baseUrl});

  Future<PaymentPrepareDto> prepare({required int transactionId}) async {
    final uri = Uri.parse('$baseUrl/api/payments/prepare');
    final res = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'transactionId': transactionId}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('prepare failed: ${res.statusCode} ${res.body}');
    }
    return PaymentPrepareDto.fromJson(jsonDecode(res.body));
  }

  Future<PaymentConfirmDto> confirm({
    required String paymentKey,
    required String orderId,
    required int amount,
  }) async {
    final uri = Uri.parse('$baseUrl/api/payments/confirm');
    final res = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'paymentKey': paymentKey,
        'orderId': orderId,
        'amount': amount,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('confirm failed: ${res.statusCode} ${res.body}');
    }
    return PaymentConfirmDto.fromJson(jsonDecode(res.body));
  }
}
