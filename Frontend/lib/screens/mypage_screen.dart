import 'dart:io'; // ✅ 로컬 파일 표시용
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sharing_items/screens/write_screen.dart';
import 'package:sharing_items/screens/edit_myinfo_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 색상 팔레트
  static const Color strong = Color(0xFF213555);
  static const Color weak = Color(0xFF3E5879);
  static const Color card = Color(0xFFD8C4B6);
  static const Color bg = Color(0xFFF5EFE7);

  // 텍스트 스타일
  TextStyle get _titleStyle => const TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  TextStyle get _bodyStyle => const TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  TextStyle get _detailStyle => const TextStyle(
    fontFamily: 'NotoSans',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.black,
  );

  // --------- 상태: 내 정보(초기값은 예시) ---------
  String? profileImageUrl;
  String userId = '아이디';
  DateTime joinDate = DateTime(2025, 8, 14);
  String address = '주소';

  // 내가 쓴 글 (WriteScreen에서 돌아온 내용을 쌓아 보여줌)
  final List<MyPost> myPosts = [];

  // 임시 데이터: 대여내역
  final List<RentalItem> myRentals = [];

  String _dateText(DateTime d) =>
      "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(61),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          //centerTitle: true,
          titleSpacing: 16,
          title: Row(
            children: [
              const Icon(
                Icons.person,
                color: Colors.black,
                size: 32,
              ),
              const SizedBox(width: 8),
              const Text(
                '마이페이지',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionHeader(title: '내 정보'),
              const SizedBox(height: 8),
              _buildMyInfoCard(
                context,
                profileImageUrl: profileImageUrl,
                userId: userId,
                joinedAt: _dateText(joinDate),
                address: address,
              ),
              const SizedBox(height: 20),

              _SectionHeader(
                title: '내가 쓴 글',
                trailing: TextButton(
                  onPressed: () => _onWriteTapped(context),
                  child: Row(
                    children: [
                      const Text(
                        '작성하기',
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SvgPicture.asset(
                        'assets/icons/chevron-right.svg',
                        width: 16,
                        height: 16,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _MyPostsArea(
                posts: myPosts,
                bodyStyle: _bodyStyle,
                detailStyle: _detailStyle,
              ),

              const SizedBox(height: 24),
              const _SectionHeader(title: '대여 내역'),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myRentals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _RentalTile(item: myRentals[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------- 위젯들 ---------
  Widget _buildMyInfoCard(
    BuildContext context, {
    required String? profileImageUrl,
    required String userId,
    required String joinedAt,
    required String address,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: weak.withOpacity(0.25)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: () {
              // ✅ 로컬/네트워크 모두 지원
              if (profileImageUrl == null || profileImageUrl!.isEmpty) {
                return Container(
                  width: 64,
                  height: 64,
                  color: Colors.white,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.black,
                  ),
                );
              }
              final url = profileImageUrl!;
              if (url.startsWith('http')) {
                return Image.network(
                  url,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                );
              } else {
                final localPath = url.replaceFirst('file://', '');
                return Image.file(
                  File(localPath),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                );
              }
            }(),
          ),
          const SizedBox(width: 16),

          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userId,
                  style: _bodyStyle.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text(joinedAt, style: _detailStyle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(address, style: _detailStyle),
              ],
            ),
          ),
          const SizedBox(width: 8),

          SizedBox(
            height: 36,
            child: OutlinedButton(
              onPressed: () => _onEditTapped(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                textStyle: const TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 14,
                ),
              ),
              child: const Text('수정'),
            ),
          ),
        ],
      ),
    );
  }

  // --------- 액션들 ---------
  Future<void> _onEditTapped(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditMyInfoScreen(
          initialUserId: userId,
          initialJoinDate: joinDate,
          initialAddress: address,
          initialProfileImageUrl: profileImageUrl,
        ),
      ),
    );

    if (!mounted) return;
    if (result != null && result is Map) {
      setState(() {
        userId = (result['userId'] as String?) ?? userId;
        address = (result['address'] as String?) ?? address;
        profileImageUrl =
            (result['profileImageUrl'] as String?) ?? profileImageUrl;

        final iso = result['joinDate'] as String?;
        if (iso != null) {
          try {
            joinDate = DateTime.parse(iso);
          } catch (_) {}
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('정보가 저장되었습니다.')));
    }
  }

  Future<void> _onWriteTapped(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WriteScreen()),
    );

    if (!mounted) return;

    // WriteScreen에서 Map 형태로 결과를 돌려준다고 가정
    if (result is Map) {
      try {
        final post = MyPost.fromMap(result);
        setState(() {
          myPosts.insert(0, post); // 최신 글을 위로
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('글이 등록되었습니다.')));
      } catch (_) {
        // 결과 형식이 다를 경우 무시
      }
    }
  }
}

// ================== 보조 위젯들 ==================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _MyPostsArea extends StatelessWidget {
  const _MyPostsArea({
    required this.posts,
    required this.bodyStyle,
    required this.detailStyle,
  });

  final List<MyPost> posts;
  final TextStyle bodyStyle;
  final TextStyle detailStyle;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: _MyPageScreenState.bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _MyPageScreenState.weak.withOpacity(0.2)),
        ),
        child: const Text(
          '아직 작성한 글이 없습니다.',
          style: TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 16,
            color: _MyPageScreenState.strong,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _MyPageScreenState.weak.withOpacity(0.2)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = posts[index];
          return ListTile(
            title: Text(p.title, style: bodyStyle),
            subtitle: Text(
              '등록일 ${p.createdAt.year}.${p.createdAt.month.toString().padLeft(2, '0')}.${p.createdAt.day.toString().padLeft(2, '0')}',
              style: detailStyle,
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: _MyPageScreenState.weak,
            ),
            onTap: () {
              // TODO: 상세 페이지로 이동하고 싶다면 여기 연결
            },
          );
        },
      ),
    );
  }
}

class _RentalTile extends StatelessWidget {
  const _RentalTile({required this.item});
  final RentalItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _MyPageScreenState.bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _MyPageScreenState.weak.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 56,
            height: 56,
            color: Colors.white,
            child: Icon(
              item.thumbnail,
              size: 32,
              color: _MyPageScreenState.weak,
            ),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontFamily: 'NotoSans',
            fontSize: 16,
            color: _MyPageScreenState.strong,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              '대여기간  ${item.period}',
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '가격  ${item.price}',
              style: const TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}

class RentalItem {
  final String title;
  final String period;
  final String price;
  final IconData thumbnail;

  RentalItem({
    required this.title,
    required this.period,
    required this.price,
    required this.thumbnail,
  });
}

// ===== 내가 쓴 글 모델 =====
class MyPost {
  final String title;
  final DateTime createdAt;

  MyPost({required this.title, required this.createdAt});

  factory MyPost.fromMap(Map data) {
    return MyPost(
      title: (data['title'] as String?) ?? '제목 없음',
      createdAt:
          DateTime.tryParse((data['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }
}
