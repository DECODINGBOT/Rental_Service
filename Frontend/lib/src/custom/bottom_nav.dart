import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white,//const Color(0xFFF5EFE7),
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.black,//const Color(0xFF213555),
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case 1:
            Navigator.pushReplacementNamed(context, '/category'); //search로 바꿀 예정
            break;
          case 2:
            Navigator.pushReplacementNamed(context, '/favorites');
            break;
          case 3:
            Navigator.pushReplacementNamed(context, '/mypage');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/home');
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: '채팅'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: '커뮤니티'),
        BottomNavigationBarItem(icon: Icon(Icons.star), label: '즐겨찾기'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
      ],
    );
  }
}