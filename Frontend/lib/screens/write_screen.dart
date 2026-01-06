import 'dart:io'; // NEW
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart'; // NEW
import 'package:sharing_items/screens/detail_screen.dart'; // 경로 맞게

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  // Design palette
  static const Color strong = Color(0xFF213555);
  static const Color weak = Color(0xFF3E5879);
  static const Color bg = Color(0xFFF5EFE7);

  // Controllers
  final _titleCtrl = TextEditingController();
  final _placeCtrl = TextEditingController();
  final _priceCtrl = TextEditingController(); // 1일 가격
  final _depositCtrl = TextEditingController(); // 보증금
  final _descCtrl = TextEditingController(); // 상세 설명

  final _formKey = GlobalKey<FormState>();

  DateTime? _startDate;
  DateTime? _endDate;

  // --- NEW: 이미지 관련 상태 ---
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = []; // 선택된 이미지들

  // ---- helpers ----
  InputDecoration _boxInput(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.black54),
    filled: true,
    fillColor: const Color(0xFFF5EFE7),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 20),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    ),
  );

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate ?? now)
        : (_endDate ?? (_startDate ?? now));
    final first = DateTime(now.year - 1);
    final last = DateTime(now.year + 3);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: const ColorScheme.light(primary: strong)),
          child: child!,
        );
      },
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  String _dateText(DateTime? d, String placeholder) =>
      d == null ? placeholder : "${d.year}.${_two(d.month)}.${_two(d.day)}";
  String _two(int n) => n.toString().padLeft(2, '0');

  // --- NEW: 이미지 픽커 동작 ---
  Future<void> _showPickSheet() async {
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
      final files = await _picker.pickMultiImage(
        imageQuality: 85, // 용량 절약
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (files.isEmpty) return;
      setState(() {
        _images.addAll(files);
      });
    } on PlatformException catch (e) {
      _showError('갤러리에서 이미지를 불러오지 못했어요: ${e.message}');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );
      if (file == null) return;
      setState(() {
        _images.add(file);
      });
    } on PlatformException catch (e) {
      _showError('카메라를 사용할 수 없어요: ${e.message}');
    }
  }

  void _removeImageAt(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ▼▼▼ 여기서 MyPage로 결과(Map)를 전달 ▼▼▼
  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // --- NEW: 최소 1장 검증 ---
    if (_images.isEmpty) {
      _showError('최소 1장 이상의 사진을 등록해 주세요.');
      return;
    }

    if (_startDate == null || _endDate == null) {
      _showError('대여 가능 기간을 선택해 주세요.');
      return;
    }

    // TODO: 업로드 로직(이미지/데이터 전송) 연결
    // 예: Firebase Storage 업로드 후 다운로드 URL 수집 -> Firestore/서버에 상품 데이터 저장
    // final urls = await _uploadAllImages(_images);

    // ✅ 작성 결과를 MyPage로 전달
    Navigator.pop(context, {
      // MyPage에서 사용할 핵심 값들
      'title': _titleCtrl.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),

      // 필요하면 MyPage에서 더 활용할 수 있도록 추가 정보도 함께 전달(있어도 무방)
      'place': _placeCtrl.text.trim(),
      'pricePerDay': _priceCtrl.text.trim(),
      'deposit': _depositCtrl.text.trim(),
      'desc': _descCtrl.text.trim(),
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),

      // 로컬 이미지 경로들(업로드 전이라면 file path, 업로드 후라면 url 리스트 등으로 바꿔 전달)
      'imagePaths': _images.map((x) => x.path).toList(),
      // 'imageUrls': urls, // 업로드 후라면 이 키로 전달
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _placeCtrl.dispose();
    _priceCtrl.dispose();
    _depositCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
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
          '글쓰기',
          style: TextStyle(
            fontSize: 28,
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
                // --- NEW: 사진 업로드 영역 (미리보기 + 추가/삭제) ---
                Text(
                  '사진',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // 선택된 이미지 썸네일들
                    ..._images.asMap().entries.map((entry) {
                      final i = entry.key;
                      final file = entry.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(file.path),
                              width: 92,
                              height: 92,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: -6,
                            right: -6,
                            child: GestureDetector(
                              onTap: () => _removeImageAt(i),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    // 추가 버튼(갤러리/카메라 선택 바텀시트)
                    InkWell(
                      onTap: _showPickSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5EFE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: weak.withOpacity(0.25)),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 28,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '최소 1장 이상의 사진을 등록해 주세요.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),

                // 상품명
                _label('상품명'),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _boxInput('예: 생활자전거 26인치'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '상품명을 입력해 주세요.' : null,
                ),

                // 대여 장소
                _label('대여 장소'),
                TextFormField(
                  controller: _placeCtrl,
                  decoration: _boxInput('예: 서울시 마포구 합정동'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? '대여 장소를 입력해 주세요.'
                      : null,
                ),

                // 1일 가격
                _label('1일 가격'),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _boxInput('예: 15000 (숫자만)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? '가격을 입력해 주세요.' : null,
                ),

                // 보증금
                _label('보증금'),
                TextFormField(
                  controller: _depositCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _boxInput('예: 50000 (선택 사항)'),
                ),

                // 상세 설명
                _label('상세 설명'),
                TextFormField(
                  controller: _descCtrl,
                  decoration: _boxInput('물품 상태, 주의사항, 특징 등을 자세히 적어 주세요.'),
                  maxLines: 6,
                  minLines: 4,
                ),

                // 대여 가능 기간
                _label('대여 가능 기간'),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(isStart: true),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EFE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dateText(_startDate, '시작일 선택'),
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '~',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickDate(isStart: false),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EFE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _dateText(_endDate, '종료일 선택'),
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: strong,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      '등록하기',
                      style: TextStyle(color: Colors.white),
                    ),
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
