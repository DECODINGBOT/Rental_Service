import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/screens/chat_room_screen.dart';
import 'package:sharing_items/src/service/favorites_provider.dart';
import 'package:sharing_items/src/service/product_service.dart';
import 'package:sharing_items/src/api_config.dart';
import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/screens/payment_screen.dart';
import 'package:sharing_items/src/service/transaction_service.dart';


class ProductDetailScreen extends StatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<ProductDetailDto> _future;
  DateTime? _rentalStart;
  DateTime? _rentalEnd;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    final service = ProductService(auth.client);
    _future = service.fetchDetail(widget.productId);
  }

  String _absUrl(String urlOrPath) {
    if (urlOrPath.isEmpty) return urlOrPath;
    if (urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')) {
      return urlOrPath;
    }
    return '${ApiConfig.baseUrl}$urlOrPath';
  }

  Future<void> _pickRentalDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _rentalStart = picked;
        if (_rentalEnd != null && _rentalEnd!.isBefore(picked)) {
          _rentalEnd = null;
        }
      } else {
        _rentalEnd = picked;
      }
    });
  }

  int _calcRentalDays(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return e.difference(s).inDays + 1; // 같은 날 = 1일
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final session = auth.currentUser();
    final fav = context.watch<FavoritesProvider>();
    final isLiked = fav.isFavoriteByProductId(widget.productId);

    return FutureBuilder<ProductDetailDto>(
      future: _future,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// 에러가 난 경우
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              title: const Text('상세', style: TextStyle(color: Colors.black)),
            ),
            body: Center(
              child: Text('상세 불러오기 실패: ${snapshot.error}'),
            ),
          );
        }

        /// 데이터 없음
        final dto = snapshot.data;
        if (dto == null) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: Text('상품 정보가 없습니다.')),
          );
        }

        /// ✅ 이제 여기서부터 "서버 데이터" 기반으로 렌더링
        final isMine = session != null && session.id == dto.ownerUserId;
        final title = dto.title;
        final sellerName = dto.ownerUsername;
        final location = dto.location;
        final pricePerDayLabel = '${dto.pricePerDay}원 / day';
        final depositLabel = '보증금 ${dto.deposit}원';
        final description = dto.description;
        final thumbnailUrl = dto.thumbnailUrl;

        /*
        // 썸네일 URL(서버가 /uploads/... 주면 절대경로로 바꿔야 함)
        final thumbUrl = (thumbnailUrl == null || thumbnailUrl.isEmpty)
            ? null
            : (thumbnailUrl.startsWith('http') ? thumbnailUrl : '${ApiConfig.baseUrl}$thumbnailUrl');
         */
        final thumb = (thumbnailUrl == null || thumbnailUrl.isEmpty) ? null : _absUrl(thumbnailUrl);

        return Scaffold(
          backgroundColor: Colors.white,

          // ================= AppBar =================
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(61),
            child: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              titleSpacing: 0,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              title: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: Colors.black),
              ),
            ),
          ),

          // ================= Body =================
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 판매자 + 대화하기
                  Row(
                    children: [
                      const Icon(Icons.person, size: 22, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        sellerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChatRoomScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.black,
                        ),
                        label: const Text(
                          '대화하기',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 이미지
                  AspectRatio(
                    aspectRatio: 1.6,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                        color: Colors.grey.shade200,
                      ),
                      child: (thumb == null)
                          ? const Center(child: Icon(Icons.image, size: 60, color: Colors.black54))
                          : ClipRRect(
                        child: Image.network(
                          thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.broken_image,
                                size: 60, color: Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 제목 + 즐겨찾기
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<FavoritesProvider>().toggleByProductId(widget.productId);
                        },
                        icon: Icon(
                          isLiked ? Icons.star : Icons.star_border,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),
                  Text(
                    '$pricePerDayLabel | $depositLabel',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 대여 기간
                  const _SectionTitle(
                    icon: Icons.calendar_month,
                    title: '대여기간을 선택해주세요',
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickRentalDate(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _rentalStart == null
                                  ? '시작일 선택'
                                  : '${_rentalStart!.year}.${_rentalStart!.month.toString().padLeft(2, '0')}.${_rentalStart!.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text('~', style: TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickRentalDate(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _rentalEnd == null
                                  ? '종료일 선택'
                                  : '${_rentalEnd!.year}.${_rentalEnd!.month.toString().padLeft(2, '0')}.${_rentalEnd!.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    (_rentalStart != null && _rentalEnd != null)
                        ? '총 ${_calcRentalDays(_rentalStart!, _rentalEnd!)}일'
                        : '대여 일수를 선택하면 결제 금액이 계산됩니다.',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),

                  const SizedBox(height: 18),


                  /// 위치
                  const Text(
                    '위치',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(location, style: const TextStyle(fontSize: 14)),

                  /// 설명
                  const Text(
                    '설명',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    (description.isEmpty ? '설명 없음' : description),
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ================= 하단 버튼 =================
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    if (isMine) {
                      return;
                    }

                    final s = session;
                    if (s == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인이 필요합니다.')),
                      );
                      return;
                    }

                    // ✅ 대여기간 선택 검증
                    if (_rentalStart == null || _rentalEnd == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('대여 기간을 선택해 주세요.')),
                      );
                      return;
                    }

                    final rentalDays = _calcRentalDays(_rentalStart!, _rentalEnd!);
                    if (rentalDays <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('대여 기간이 올바르지 않습니다.')),
                      );
                      return;
                    }

                    try {
                      final txService = TransactionService(
                        auth.client,
                        baseUrl: ApiConfig.baseUrl,
                      );

                      final created = await txService.create(
                        productId: dto.id,     // dto.id가 productId 맞는지 확인(보통 맞음)
                        renterUserId: s.id,
                      );

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            transactionId: created.id,
                            rentalDays: rentalDays,          // ✅ 추가
                            orderName: dto.title,
                            customerName: s.username,
                          ),
                        ),
                      );

                      if (!mounted) return;
                      // 결제 성공이면 PaymentScreen이 confirmed dto를 pop으로 넘겨줌
                      if (result != null) {
                        // ✅ 결제 성공 후: 대여 시작 확정(startAt/endAt 서버 반영)
                        final start = _rentalStart!;
                        final end = _rentalEnd!;

                        final started = await txService.startRental(
                          transactionId: created.id,
                          startAt: start,
                          endAt: end,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('대여가 시작되었습니다. 상태: ${started.status}')),
                        );

                        // 선택사항: 화면 새로고침(상태/버튼 등 반영)
                        setState(() {
                          final auth2 = context.read<AuthService>();
                          final service2 = ProductService(auth2.client);
                          _future = service2.fetchDetail(widget.productId);
                        });

                        // 선택사항: 여기서 바로 뒤로가기
                        // Navigator.pop(context, true);
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('대여하기 실패: $e')),
                      );
                    }
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isMine ? '수정하기' : '대여하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

// ================= Components =================

class _SearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;

  const _SearchBar({required this.hint, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                hint,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
