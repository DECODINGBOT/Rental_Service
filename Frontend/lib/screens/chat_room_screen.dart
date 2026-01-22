import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  late final List<ChatItem> _items = _seedItems();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _items.add(ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
        isMe: true,
        createdAt: DateTime.now(),
      ));
    });

    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    const nickname = '거래자 닉네임';
    final product = DealProduct(title: '닌텐도 스위치 라이트', priceLabel: '95,000원');

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(61),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            tooltip: '뒤로',
          ),
          title: Text(
            nickname,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: 신고/차단/거래상태 등
              },
              icon: const Icon(Icons.more_vert, color: Colors.black),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.black),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _DealInfoBar(
              product: product,
              onTap: () {
                // TODO: 상품 상세로 이동
              },
              onConfirmPressed: () {
                setState(() {
                  _items.add(ChatSystemMessage(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    text: '거래가 확정되었습니다. 약속 장소와 시간을 확인해 주세요.',
                    createdAt: DateTime.now(),
                  ));
                });
                _scrollToBottom();
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];

                    if (item is ChatDayDivider) {
                      return _DayDivider(label: item.label);
                    }
                    if (item is ChatSystemMessage) {
                      return _SystemBubble(text: item.text);
                    }

                    final msg = item as ChatMessage;
                    final prev = _findPrevMessage(index);

                    final showTime = prev == null ||
                        prev.isMe != msg.isMe ||
                        msg.createdAt.difference(prev.createdAt).inMinutes >= 5;

                    final isGroupBreak = prev == null || prev.isMe != msg.isMe;

                    return Padding(
                      padding: EdgeInsets.only(top: isGroupBreak ? 10 : 2, bottom: 2),
                      child: _ChatBubble(
                        message: msg,
                        showTime: showTime,
                      ),
                    );
                  },
                ),
              ),
            ),
            _ChatInputBar(
              controller: _textController,
              onSend: _send,
              onPlusPressed: () {
                // TODO: 사진/장소/제안 등
              },
            ),
          ],
        ),
      ),
    );
  }

  ChatMessage? _findPrevMessage(int index) {
    for (int i = index - 1; i >= 0; i--) {
      final item = _items[i];
      if (item is ChatMessage) return item;
    }
    return null;
  }
}

// ---------- Deal header (app tone: white + black 1px + r=8) ----------

class DealProduct {
  final String title;
  final String priceLabel;

  DealProduct({required this.title, required this.priceLabel});
}

class _DealInfoBar extends StatelessWidget {
  final DealProduct product;
  final VoidCallback onTap;
  final VoidCallback onConfirmPressed;

  const _DealInfoBar({
    required this.product,
    required this.onTap,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: const Icon(Icons.image, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.priceLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onConfirmPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                child: const Text(
                  '거래확정',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Chat list items ----------

sealed class ChatItem {
  final String id;
  final DateTime createdAt;
  ChatItem({required this.id, required this.createdAt});
}

class ChatMessage extends ChatItem {
  final String text;
  final bool isMe;

  ChatMessage({
    required super.id,
    required this.text,
    required this.isMe,
    required super.createdAt,
  });
}

class ChatSystemMessage extends ChatItem {
  final String text;

  ChatSystemMessage({
    required super.id,
    required this.text,
    required super.createdAt,
  });
}

class ChatDayDivider extends ChatItem {
  final String label;

  ChatDayDivider({
    required super.id,
    required this.label,
    required super.createdAt,
  });
}

// ---------- Widgets ----------

class _DayDivider extends StatelessWidget {
  final String label;
  const _DayDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
        ],
      ),
    );
  }
}

class _SystemBubble extends StatelessWidget {
  final String text;
  const _SystemBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showTime;

  const _ChatBubble({
    required this.message,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, size: 18, color: Colors.black54),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? Colors.white : Colors.grey.shade50,
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.25,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            if (isMe) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person, size: 18, color: Colors.black54),
              ),
            ],
          ],
        ),
        if (showTime) ...[
          const SizedBox(height: 4),
          Text(
            _formatTime(message.createdAt),
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = hour < 12 ? '오전' : '오후';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$ampm $hour12:$minute';
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPlusPressed;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.onPlusPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPlusPressed,
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: '첨부',
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            onPressed: onSend,
            icon: const Icon(Icons.send, color: Colors.black),
            tooltip: '전송',
          ),
        ],
      ),
    );
  }
}

// ---------- Seed data (dummy) ----------

List<ChatItem> _seedItems() {
  final now = DateTime.now();

  DateTime t(int minutesAgo) => now.subtract(Duration(minutes: minutesAgo));

  return [
    ChatDayDivider(id: 'd1', label: '오늘', createdAt: t(120)),
    ChatSystemMessage(
      id: 's1',
      text: '안전한 거래를 위해 개인정보 공유는 주의해 주세요.',
      createdAt: t(119),
    ),
    ChatMessage(id: 'm1', text: '안녕하세요! 아직 판매 중인가요?', isMe: false, createdAt: t(55)),
    ChatMessage(id: 'm2', text: '네 판매 중이에요 🙂', isMe: true, createdAt: t(54)),
    ChatMessage(id: 'm3', text: '오늘 저녁 8시쯤 직거래 가능할까요?', isMe: false, createdAt: t(50)),
    ChatMessage(id: 'm4', text: '가능해요! 장소는 어디가 편하세요?', isMe: true, createdAt: t(49)),
  ];
}
