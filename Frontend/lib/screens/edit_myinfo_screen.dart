import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditMyInfoScreen extends StatefulWidget {
  const EditMyInfoScreen({
    super.key,
    this.initialUserId = '아이디',
    this.initialJoinDate,
    this.initialAddress = '',
    this.initialDetailAddress = '',
    this.initialPhone = '',
    this.initialAbout = '',
    this.initialProfileImageUrl,
  });

  // ── 초기값들 ───────────────────────────────────────────────────────────────
  final String initialUserId;
  final DateTime? initialJoinDate;
  final String initialAddress;
  final String initialDetailAddress;
  final String initialPhone;
  final String initialAbout;
  final String? initialProfileImageUrl;

  @override
  State<EditMyInfoScreen> createState() => _EditMyInfoScreenState();
}

class _EditMyInfoScreenState extends State<EditMyInfoScreen> {
  // 디자인 팔레트
  static const Color strong = Color(0xFF213555);
  static const Color inputBg = Color(0xFFF5EFE7);

  // 컨트롤러 (초기값은 initState에서 세팅)
  late final TextEditingController _idCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _addrDetailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _aboutCtrl;

  // 가입일은 읽기 전용으로 표시
  late DateTime _joinDate;
  String? _profileImageUrl;

  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedProfile; // 새로 고른 로컬 이미지
  bool _saving = false; // 저장 중 인디케이터

  @override
  void initState() {
    super.initState();
    // ⬇⬇⬇ 여기서 초기값을 컨트롤러에 넣어줍니다.
    _idCtrl = TextEditingController(text: widget.initialUserId);
    _addrCtrl = TextEditingController(text: widget.initialAddress);
    _addrDetailCtrl = TextEditingController(text: widget.initialDetailAddress);
    _phoneCtrl = TextEditingController(text: widget.initialPhone);
    _aboutCtrl = TextEditingController(text: widget.initialAbout);

    _joinDate = widget.initialJoinDate ?? DateTime.now();
    _profileImageUrl = widget.initialProfileImageUrl;
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _addrCtrl.dispose();
    _addrDetailCtrl.dispose();
    _phoneCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  InputDecoration _input(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black45),
    filled: true,
    fillColor: inputBg,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),
  );

  Future<void> _showProfilePickSheet() async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리에서 선택'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라로 촬영'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (file == null) return;
      setState(() {
        _pickedProfile = file; // 미리보기는 로컬 파일로
      });
    } catch (e) {
      _snack('갤러리에서 이미지를 불러오지 못했어요: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (file == null) return;
      setState(() {
        _pickedProfile = file;
      });
    } catch (e) {
      _snack('카메라를 사용할 수 없어요: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _dateText(DateTime d) =>
      "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";

  // ▼▼▼ 저장 로직 보강: _pickedProfile가 있으면 file:// 경로로 넘김 (업로드 미사용 버전) ▼▼▼
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    String? finalProfileUrl = _profileImageUrl;

    if (_pickedProfile != null) {
      // [옵션 A] 업로드 없이 로컬 경로 전달 (MyPage에서 Image.file로 표시)
      finalProfileUrl = 'file://${_pickedProfile!.path}';

      // [옵션 B] 업로드를 사용하려면 아래 주석을 해제하고 _uploadProfile 구현
      // try {
      //   final url = await _uploadProfile(File(_pickedProfile!.path), _idCtrl.text.trim());
      //   finalProfileUrl = url;
      // } catch (e) {
      //   _snack('프로필 업로드 실패: $e');
      //   setState(() => _saving = false);
      //   return;
      // }
    }

    setState(() => _saving = false);

    // 저장 결과를 Map으로 되돌려 보내 마이페이지에서 setState로 반영
    Navigator.pop(context, {
      'userId': _idCtrl.text.trim(),
      'joinDate': _joinDate.toIso8601String(),
      'address': _addrCtrl.text.trim(),
      'detailAddress': _addrDetailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'about': _aboutCtrl.text.trim(),
      'profileImageUrl': finalProfileUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5A73),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '내 정보 수정',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필 이미지
                Row(
                  children: [
                    GestureDetector(
                      onTap: _showProfilePickSheet, // ← 탭 시 사진 선택 시트
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Builder(
                            builder: (_) {
                              if (_pickedProfile != null) {
                                return Image.file(
                                  File(_pickedProfile!.path),
                                  fit: BoxFit.cover,
                                );
                              }
                              if (_profileImageUrl != null &&
                                  _profileImageUrl!.isNotEmpty) {
                                if (_profileImageUrl!.startsWith('http')) {
                                  return Image.network(
                                    _profileImageUrl!,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  // file:// 로컬 경로도 지원
                                  final local = _profileImageUrl!.replaceFirst(
                                    'file://',
                                    '',
                                  );
                                  return Image.file(
                                    File(local),
                                    fit: BoxFit.cover,
                                  );
                                }
                              }
                              return const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.black87,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        '프로필 사진을 탭하여 변경할 수 있어요.',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),

                _label('아이디'),
                TextFormField(
                  controller: _idCtrl,
                  decoration: _input('아이디'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '아이디를 입력해 주세요.' : null,
                ),

                _label('가입일'),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: inputBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _dateText(_joinDate), // ← 초기값 표시됨
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),

                _label('주소'),
                TextFormField(
                  controller: _addrCtrl, // ← 초기값 표시됨
                  decoration: _input('예: 서울시 마포구 합정동'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '주소를 입력해 주세요.' : null,
                ),

                _label('상세 주소'),
                TextFormField(
                  controller: _addrDetailCtrl, // ← 초기값 표시됨
                  decoration: _input('예: 00아파트 101동 1001호'),
                ),

                _label('연락처'),
                TextFormField(
                  controller: _phoneCtrl, // ← 초기값 표시됨
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
                  ],
                  decoration: _input('예: 010-1234-5678'),
                ),

                _label('자기소개 (선택)'),
                TextFormField(
                  controller: _aboutCtrl, // ← 초기값 표시됨
                  maxLines: 4,
                  minLines: 3,
                  decoration: _input('간단한 소개를 적어 주세요.'),
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: strong,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('저장하기'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
