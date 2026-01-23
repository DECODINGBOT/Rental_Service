import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sharing_items/src/api_config.dart';
import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/src/service/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  final int transactionId;

  /// orderName/customerName은 일단 파라미터로 받게 해두면 좋아
  final String orderName;
  final String customerName;

  const PaymentScreen({
    super.key,
    required this.transactionId,
    required this.orderName,
    required this.customerName,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;

  bool _loading = true;
  String? _error;

  // 토스 테스트 클라이언트 키(네가 준 값)
  static const String _clientKey = "test_ck_D5GePWvyJnrK0W0k6q8gLzN97Eoq";

  // 앱 스킴 (Manifest/Info.plist와 동일해야 함)
  static const String _appScheme = "lendyapp";

  // success/fail URL은 “앱에서 인터셉트하기 쉬운 도메인”으로
  // 개발 중이면 아무 https 도메인으로 해도 되고, 실제 서비스면 네 도메인으로.
  static const String _successUrl = "lendyapp://pay/success";
  static const String _failUrl = "lendyapp://pay/fail";


  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) async {
            final url = request.url;

            // 1) 토스 결제 성공/실패 URL 인터셉트
            if (url.startsWith(_successUrl)) {
              await _handleSuccess(url);
              return NavigationDecision.prevent;
            }
            if (url.startsWith(_failUrl)) {
              await _handleFail(url);
              return NavigationDecision.prevent;
            }

            // 2) intent:// / market:// / ispmobile:// 같은 외부앱 호출 처리
            // 토스 공식 플러그인 사용: intent -> app scheme 변환
            if (url.startsWith('intent://')) {
              await _handleIntentUrl(url);
              return NavigationDecision.prevent;
            }
            if (url.startsWith('market://')) {
              await _launchExternal(url);
              return NavigationDecision.prevent;
            }


            // 일부 카드사/은행앱 스킴
            if (_looksLikeAppScheme(url)) {
              await _launchExternal(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _boot();
  }

  String? _extractPackageFromIntent(String url) {
    // intent://...#Intent;scheme=...;package=com.kbcard...;end
    final idx = url.indexOf('package=');
    if (idx == -1) return null;
    final sub = url.substring(idx + 'package='.length);
    final end = sub.indexOf(';');
    return end == -1 ? sub : sub.substring(0, end);
  }

  Future<void> _handleIntentUrl(String url) async {
    final pkg = _extractPackageFromIntent(url);
    if (pkg != null) {
      final market = Uri.parse('market://details?id=$pkg');
      try {
        await launchUrl(market, mode: LaunchMode.externalApplication);
        return;
      } catch (_) {}
    }

    // 그래도 시도
    await _launchExternal(url);
  }


  bool _looksLikeAppScheme(String url) {
    // http/https가 아닌 스킴이면 외부앱 호출로 본다
    return !(url.startsWith('http://') || url.startsWith('https://'));
  }

  Future<void> _launchExternal(String url) async {
    try {
      // market:// 또는 기타 스킴은 그대로 실행 시도
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // 외부앱이 없으면 실패할 수 있음
      debugPrint('launchExternal failed: $e');
    }
  }

  Future<void> _boot() async {
    try {
      final auth = context.read<AuthService>();
      final paymentService = PaymentService(
        auth.client,
        baseUrl: ApiConfig.baseUrl,
      );

      // 1) 서버 prepare
      final prepared = await paymentService.prepare(
        transactionId: widget.transactionId,
      );

      // 2) 결제 HTML 로드 (prepared.orderId, prepared.amount를 주입)
      final html = _buildPaymentHtml(
        amount: prepared.amount,
        orderId: prepared.orderId,
        orderName: widget.orderName,
        customerName: widget.customerName,
      );

      await _controller.loadHtmlString(html);
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  String _buildPaymentHtml({
    required int amount,
    required String orderId,
    required String orderName,
    required String customerName,
  }) {
    // JS에 들어갈 문자열은 JSON 인코딩으로 안전하게 escape
    final safeOrderId = jsonEncode(orderId);
    final safeOrderName = jsonEncode(orderName);
    final safeCustomerName = jsonEncode(customerName);

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>결제하기</title>
  <script src="https://js.tosspayments.com/v1/payment"></script>
</head>
<body>
  <script>
    (function() {
      var clientKey = "${_clientKey}";
      var tossPayments = TossPayments(clientKey);

      tossPayments.requestPayment("카드", {
        amount: ${amount},
        orderId: ${safeOrderId},
        orderName: ${safeOrderName},
        customerName: ${safeCustomerName},
        successUrl: "${_successUrl}",
        failUrl: "${_failUrl}",
        appScheme: "${_appScheme}"
      }).catch(function(error) {
        // Flutter가 직접 JS 에러를 받기 어렵기 때문에 failUrl로 보내거나,
        // location.href로 커스텀 failUrl 호출해도 됨
        console.log(error);
      });
    })();
  </script>
</body>
</html>
''';
  }

  Future<void> _handleSuccess(String url) async {
    try {
      final uri = Uri.parse(url);
      final paymentKey = uri.queryParameters['paymentKey'];
      final orderId = uri.queryParameters['orderId'];
      final amountStr = uri.queryParameters['amount'];

      if (paymentKey == null || orderId == null || amountStr == null) {
        throw Exception('successUrl missing params: $url');
      }

      final amount = int.parse(amountStr);

      final auth = context.read<AuthService>();
      final paymentService = PaymentService(
        auth.client,
        baseUrl: ApiConfig.baseUrl,
      );

      // 서버 confirm
      final confirmed = await paymentService.confirm(
        paymentKey: paymentKey,
        orderId: orderId,
        amount: amount,
      );

      if (!mounted) return;

      // 결제 완료 -> 이전 화면으로 결과 전달
      Navigator.pop(context, confirmed);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '결제 확인 실패: $e');
    }
  }

  Future<void> _handleFail(String url) async {
    if (!mounted) return;
    setState(() => _error = '결제 실패: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('결제하기'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else
            WebViewWidget(controller: _controller),

          if (_loading)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
