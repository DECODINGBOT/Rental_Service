List<Map<String, dynamic>> mockItems = [
  {
    "id": "i1",
    "category": "자동차용품",
    "title": "블랙박스 새상품",
    "location": "서울 강남구",
    "price": 85000,
    "period": "1일",
    "imageUrl": "https://picsum.photos/seed/blackbox/120",
    "isLike": true,
  },
  {
    "id": "i2",
    "category": "전자/가전제품",
    "title": "아이패드 9세대 64GB",
    "location": "서울 송파구",
    "price": 290000,
    "period": "2주",
    "imageUrl": "https://picsum.photos/seed/ipad9/120",
    "isLike": false,
  },
  {
    "id": "i3",
    "category": "의류/신발",
    "title": "나이키 에어포스 270",
    "location": "서울 마포구",
    "price": 70000,
    "period": "3일",
    "imageUrl": "https://picsum.photos/seed/airforce270/120",
    "isLike": true,
  },
  {
    "id": "i4",
    "category": "자동차용품",
    "title": "차량용 핸드폰 거치대",
    "location": "서울 동작구",
    "price": 10000,
    "period": "1일",
    "imageUrl": "https://picsum.photos/seed/holder/120",
    "isLike": false,
  },
];

bool isLikedById(String id) =>
    mockItems.any((m) => m['id'] == id && (m['isLike'] ?? false));

void toggleLikeById(String id) {
  final i = mockItems.indexWhere((m) => m['id'] == id);
  if (i != -1) {
    final cur = mockItems[i]['isLike'] as bool? ?? false;
    mockItems[i]['isLike'] = !cur;
  }
}
