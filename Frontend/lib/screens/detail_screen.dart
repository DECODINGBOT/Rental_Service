// detail_screen.dart
import 'package:flutter/material.dart';

/// ✅ 상세 화면에 전달할 데이터 모델
class DetailData {
  final String category;
  final String title;
  final String location;
  final int pricePerDay; // 1일 가격(원)
  final String description;
  final int? deposit; // 보증금(선택)
  final List<String> tags; // 태그(선택)
  final DateTime? startDate; // 대여 가능 시작(작성자)
  final DateTime? endDate; // 대여 가능 종료(작성자)

  const DetailData({
    required this.category,
    required this.title,
    required this.location,
    required this.pricePerDay,
    required this.description,
    this.deposit,
    this.tags = const [],
    this.startDate,
    this.endDate,
  });

  /// 데모/안전용 기본값
  factory DetailData.demo() => DetailData(
    category: '자전거',
    title: '생활자전거 26인치',
    location: '서울 성동구 사근동',
    pricePerDay: 10000,
    deposit: 50000,
    description:
        '가벼운 출퇴근/동네 마실용으로 좋은 생활자전거입니다.\n'
        '변속기 정상 동작, 기본 정비 완료. 자물쇠 포함 (헬멧 별도).',
    tags: const ['자전거', '생활용', '성동구', '자물쇠포함'],
    startDate: DateTime(2025, 8, 13),
    endDate: DateTime(2025, 8, 17),
  );
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, this.data});

  /// 직접 주입 or Route arguments 로 받을 수 있음
  final DetailData? data;

  String _won(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final r = s.length - i;
      b.write(s[i]);
      if (r > 1 && r % 3 == 1) b.write(',');
    }
    return '₩${b.toString()}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _d(DateTime dt) => '${dt.year}.${_two(dt.month)}.${_two(dt.day)}';

  String _fmtRange(DateTime a, DateTime b) => '${_d(a)}~${_d(b)}';

  Future<void> _onRequestPressed(BuildContext context, DetailData d) async {
    // 1) 작성자가 가용 기간을 설정하지 않은 경우 방어
    if (d.startDate == null || d.endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('작성자가 대여 가능 기간을 설정하지 않았습니다.')),
      );
      return;
    }

    final availableStart = d.startDate!;
    final availableEnd = d.endDate!;
    // 초기 제안 범위(가용 기간의 앞쪽 3박 정도) — 상황에 맞게 조정 가능
    final initialStart = availableStart;
    final initialEnd = availableStart.add(const Duration(days: 3));
    final initialRange = DateTimeRange(
      start: initialStart.isBefore(availableEnd)
          ? initialStart
          : availableStart,
      end: initialEnd.isAfter(availableEnd) ? availableEnd : initialEnd,
    );

    // 2) 대여자가 기간 선택 (가용 범위 밖의 날짜는 선택 불가)
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: availableStart,
      lastDate: availableEnd,
      helpText: '대여할 기간을 선택하세요',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF4A5A73)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;

    // 3) 유효성 확인(보수적 중복 체크)
    if (picked.start.isBefore(availableStart) ||
        picked.end.isAfter(availableEnd) ||
        picked.duration.inDays <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택한 기간이 유효하지 않습니다. 다시 선택해 주세요.')),
      );
      return;
    }

    final days = picked.duration.inDays; // 기존 UI 로직(종료일 미포함)과 동일하게 계산
    final totalCost = days * d.pricePerDay;

    // 4) 최종 확인 팝업
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('대여 요청 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('대여 가능 기간: ${_fmtRange(availableStart, availableEnd)}'),
            const SizedBox(height: 8),
            Text('선택한 기간: ${_fmtRange(picked.start, picked.end)}'),
            const SizedBox(height: 8),
            Text('총 대여일수: $days일'),
            const SizedBox(height: 8),
            Text('예상 결제금액: ${_won(totalCost)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // 닫기
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('대여 요청이 전송되었습니다.')));
              // TODO: 실제 요청 API 호출/네비게이션 등 연결
            },
            child: const Text('요청 보내기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1순위: 생성자 주입 / 2순위: Route arguments / 3순위: 데모값
    final DetailData d =
        data ??
        (ModalRoute.of(context)?.settings.arguments as DetailData?) ??
        DetailData.demo();

    final hasAuthorRange = d.startDate != null && d.endDate != null;
    final rangeText = hasAuthorRange
        ? _fmtRange(d.startDate!, d.endDate!)
        : '대여기간 미입력';
    final totalDays = hasAuthorRange
        ? d.endDate!.difference(d.startDate!).inDays
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5A73),
        centerTitle: true,
        title: Text(d.location, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),

      // 하단 고정 CTA
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1일 가격',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      _won(d.pricePerDay),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5A73),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _onRequestPressed(context, d),
                  child: const Text('대여 요청'),
                ),
              ),
            ],
          ),
        ),
      ),

      // 본문
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 상단 이미지 자리: 아이콘으로 대체
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(
                  Icons.pedal_bike_outlined,
                  size: 120,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: Colors.grey.shade400, height: 1),

          // 요약 정보
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _won(d.pricePerDay),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.star_border, size: 28), // 즐겨찾기(연동 전)
              ],
            ),
          ),

          // 위치
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.place_outlined, size: 18),
                const SizedBox(width: 6),
                Text(d.location, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade400, height: 24),

          // 대여 가능 기간(작성자 설정)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rangeText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (totalDays != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '총 $totalDays일',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),

          Divider(color: Colors.grey.shade300, height: 24),

          // 상세 설명
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '상세 설명',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  d.description,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade300, height: 24),

          // 보증금
          if (d.deposit != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '보증금',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _won(d.deposit!),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey.shade300, height: 24),
          ],

          // 주의사항
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주의사항',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  '• 장비 상태를 수령 즉시 확인해주세요.\n'
                  '• 파손/분실 시 수리비 또는 정가가 청구될 수 있습니다.\n'
                  '• 반납 지연 시 추가 요금이 발생할 수 있습니다.',
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade300, height: 24),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
