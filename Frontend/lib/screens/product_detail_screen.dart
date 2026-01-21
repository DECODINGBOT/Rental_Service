import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/screens/chat_room_screen.dart';
import 'package:sharing_items/src/service/favorites_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  // 홈 탭에서 진입하면 true(검색창 있는 AppBar),
  // 즐겨찾기 탭에서 진입하면 false(검색창 없는 AppBar)
  final bool showSearchBar;

  // ⭐ 즐겨찾기/채팅 연결을 위한 핵심 ID
  final String productId;

  // 지금은 더미, 나중에 모델로 교체
  final String sellerName;
  final String title;
  final String location;
  final String pricePerDayLabel;
  final String depositLabel;
  final String dateRangeLabel;

  const ProductDetailScreen({
    super.key,
    required this.showSearchBar,
    required this.productId,
    this.sellerName = '아이디',
    this.title = '물건 이름',
    this.location = '어쩌구 저쩌구',
    this.pricePerDayLabel = '0,000원 / day',
    this.depositLabel = '보증금 0,000원',
    this.dateRangeLabel = '2025.08.13~2025.08.17',
  });

  @override
  Widget build(BuildContext context) {
    final fav = context.watch<FavoritesProvider>();
    final isLiked = fav.isFavoriteById(productId);

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
          title: showSearchBar
              ? _SearchBar(hint: '원하시는 물건을 검색해주세요', onTap: () {})
              : Text(
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
                  child: const Center(
                    child: Icon(Icons.image, size: 60, color: Colors.black54),
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
                      context.read<FavoritesProvider>().toggleById(productId);
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
              const SizedBox(height: 6),
              Text(
                dateRangeLabel,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              // 위치
              const Text(
                '위치',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(location, style: const TextStyle(fontSize: 14)),

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
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '대여하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
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
