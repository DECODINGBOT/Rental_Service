import 'package:flutter/material.dart';
import 'package:sharing_items/screens/community_detail_screen.dart';
import 'package:sharing_items/screens/community_write_screen.dart';
import 'package:sharing_items/src/service/community_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {

  final _searchController = TextEditingController();
  final _communityService = CommunityService();
  String _keyword = '';
  late Future<List<CommunityListItemDto>> _future;

  @override
  void initState(){
    super.initState();
    _future = _communityService.fetchBoards();
  }

  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }

  void _refresh(){
    setState(() {
      _future = _communityService.fetchBoards();
    });
  }

  List<CommunityListItemDto> _filter(List<CommunityListItemDto> all){
    final k = _keyword.trim().toLowerCase();
    if(k.isEmpty){
      return all;
    }
    return all.where((e){
      return e.title.toLowerCase().contains(k) ||
          e.preview.toLowerCase().contains(k);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(121),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: Colors.black,
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '커뮤니티',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                  
                      const Spacer(),
                  
                      IconButton(
                        onPressed: () async {
                          final changed = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => const CommunityWriteScreen()),
                          );
                          if(changed == true){
                            _refresh();
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 28,
                        ),
                      ),

                      IconButton(
                          onPressed: _refresh,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 26,
                          )
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _keyword = v),
                      decoration: InputDecoration(
                        hintText: " ",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  )
                ],
              ),
            ),
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
        child: FutureBuilder<List<CommunityListItemDto>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
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

            final all = snapshot.data ?? [];
            final items = _filter(all);

            if (items.isEmpty) {
              return const Center(
                child: Text('게시글이 없습니다.'),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              separatorBuilder: (_, _) =>
              const Divider(height: 20, thickness: 1, color: Colors.black),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildBoardItem(items[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBoardItem(CommunityListItemDto item){
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => CommunityDetailScreen(boardId: item.id),
          ),
        );
        _refresh();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.preview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.thumb_up_alt_outlined,
                  size: 18,
                  color: Colors.black,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.likeCount}',
                  style: const TextStyle(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: Colors.black,
                ),
                const SizedBox(width: 4),
                Text(
                  '${item.commentCount}',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 12),
                Text(
                  '| ${item.username}',
                  style: const TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}