import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
                Icons.chat,
                color: Colors.black,
                size: 32,
              ),
              const SizedBox(width: 8),
              const Text(
                '채팅',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),

              const Spacer(),

              IconButton(
                onPressed: () {
                  //TODO: 검색버튼 동작->닉네임 검색
                },
                icon: const Icon(
                  Icons.search,
                  color: Colors.black,
                  size: 28,
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
      
      //TODO: body 부분 구현
    );
  }
}