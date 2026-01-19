import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/src/api_config.dart';
import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/src/service/community_service.dart';

class CommunityDetailScreen extends StatefulWidget {

  final int boardId;

  const CommunityDetailScreen({
    super.key,
    required this.boardId,
  });

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final _communityService = CommunityService();
  late Future<CommunityDetailDto> _future;
  final _commentController = TextEditingController();
  final _commentFocus = FocusNode();
  bool _sending = false;

  @override
  void initState(){
    super.initState();
    _future = _communityService.fetchBoardDetail(
      boardId: widget.boardId,
      userId: (context.read<AuthService>().currentUser())?.id,
    );
  }

  @override
  void dispose(){
    _commentController.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _refresh(){
    setState(() {
      _future = _communityService.fetchBoardDetail(
        boardId: widget.boardId,
        userId: (context.read<AuthService>().currentUser())?.id,
      );
    });
  }

  Future<void> _submitComment() async {
    if(_sending) return;

    final content = _commentController.text.trim();
    if(content.isEmpty) return;

    final auth = context.read<AuthService>();
    final me = auth.currentUser();
    if(me == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    setState(() => _sending = true);

    try{
      await _communityService.addComment(
        boardId: widget.boardId,
        userId: me.id,
        content: content,
      );
      _commentController.clear();
      _commentFocus.unfocus();
      _refresh();
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _absUrl(String urlOrPath){
    if(urlOrPath.isEmpty) return urlOrPath;
    if(urlOrPath.startsWith('http://') || urlOrPath.startsWith('https://')){
      return urlOrPath;
    }
    const baseUrl = ApiConfig.baseUrl;
    return '$baseUrl$urlOrPath';
  }
  
  String formatYMDHM(String iso){
    if(iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if(dt == null) return iso;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}.${two(dt.month)}.${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '게시글',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<CommunityDetailDto>(
          future: _future,
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            }
            if(snapshot.hasError){
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '불러오기 실패\n${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('다시 시도'),
                    ),
                  ],
                ),
              );
            }
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(data),
                  const SizedBox(height: 14),
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data.content,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if(data.imageUrls.isNotEmpty)...[
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.imageUrls.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index){
                          final url = data.imageUrls[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 160,
                              color: Colors.black12,
                              child: Image.network(
                                _absUrl(url),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final me = context.read<AuthService>().currentUser();
                          if(me == null){
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그인이 필요합니다.')),
                            );
                            return;
                          }

                          try{
                            final result = await _communityService.toggleLike(
                              boardId: data.id,
                              userId: me.id,
                            );
                            _refresh();
                          } catch (e){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('좋아요 실패: $e')),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              data.liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${data.likeCount}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      /*
                      const Icon(Icons.thumb_up_alt_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text('${data.likeCount}', style: const TextStyle(fontSize: 13)),
                      */
                      const SizedBox(width: 14),
                      const Icon(Icons.chat_bubble_outline, size: 18),
                      const SizedBox(width: 6),
                      Text('${data.commentCount}', style: const TextStyle(fontSize: 13)),

                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(thickness: 1, color: Colors.black),
                  const SizedBox(height: 12),

                  const Text(
                    '댓글',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),

                  if(data.comments.isEmpty)
                    const Text('댓글이 없습니다')
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: data.comments.length,
                      separatorBuilder: (_, _) => const Divider(height: 16),
                      itemBuilder: (context, index){
                        final c = data.comments[index];
                        return _commentTile(c);
                      },
                    ),

                ],
              ),
            );
          }
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocus,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                      onPressed: _sending ? null : _submitComment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _sending
                          ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2),)
                          : const Text('등록', style: TextStyle(fontWeight: FontWeight.w900),)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(CommunityDetailDto data){
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.black12,
          backgroundImage: (data.profileImageUrl == null || data.profileImageUrl!.isEmpty)
              ? null
              : NetworkImage(_absUrl(data.profileImageUrl!)),
          child: (data.profileImageUrl == null || data.profileImageUrl!.isEmpty)
              ? const Icon(Icons.person, size: 18, color: Colors.black54)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            data.username,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        Text(
          formatYMDHM(data.createdAt),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _commentTile(CommentDto c){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.black12,
          backgroundImage: (c.profileImageUrl == null || c.profileImageUrl!.isEmpty)
              ? null
              : NetworkImage(_absUrl(c.profileImageUrl!)),
          child: (c.profileImageUrl == null || c.profileImageUrl!.isEmpty)
              ? const Icon(Icons.person, size: 16, color: Colors.black54)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      c.username,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Text(
                    formatYMDHM(c.createdAt),
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(c.content),
            ],
          ),
        )
      ],
    );
  }
}
