import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sharing_items/src/service/auth_service.dart';
import 'package:sharing_items/src/service/community_service.dart';

class CommunityWriteScreen extends StatefulWidget {
  const CommunityWriteScreen({super.key});

  @override
  State<CommunityWriteScreen> createState() => _CommunityWriteScreenState();
}

class _CommunityWriteScreenState extends State<CommunityWriteScreen> {

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _picker = ImagePicker();
  final _communityService = CommunityService();
  final List<XFile> _images = [];
  bool _loading = false;

  @override
  void dispose(){
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if(picked.isEmpty) return;
    setState(() {
      _images.addAll(picked);
    });
  }

  Future<void> _submit() async {
    if(_loading) return;

    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if(title.isEmpty || content.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목/내용을 입력해주세요')),
      );
      return;
    }

    final auth = context.read<AuthService>();
    final me = auth.currentUser();
    if(me == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }
    setState(() => _loading = true);

    try{
      final files = _images.map((x) => File(x.path)).toList();
      final created = await _communityService.createBoard(
        title: title,
        content: content,
        userId: me.id,
        images: files,
      );

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('등록 완료')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 실패: $e')),
      );
    } finally {
      if(mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '글쓰기',
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
          TextButton(
              onPressed: _loading ? null : _submit,
              child: Text(
                _loading ? '등록중...' : '등록',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              minLines: 8,
              maxLines: 14,
              decoration: const InputDecoration(
                hintText: '내용',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                OutlinedButton.icon(
                    onPressed: _loading ? null : _pickImages,
                    icon: const Icon(Icons.photo, color: Colors.black),
                    label: Text(
                      '사진 선택 (${_images.length})',
                      style: const TextStyle(color: Colors.black),
                    ),
                ),
                const Spacer(),
                if(_images.isNotEmpty)
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _images.clear()),
                    child: const Text(
                      '전체 삭제',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
              ],
            ),

            if(_images.isNotEmpty)...[
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index){
                    final x = _images[index];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(x.path),
                            width: 120,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: InkWell(
                            onTap: _loading
                                ? null
                                : () => setState(() => _images.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              )
            ]
          ],
        )
      ),
    );
  }
}
