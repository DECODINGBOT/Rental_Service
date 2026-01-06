import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sharing_items/const/Colors.dart';

class ItemInfo extends StatefulWidget {
  final String category;
  final String title;
  final String location;
  final int price;
  final bool isLike;

  // ✅ 추가: 즐겨찾기 토글되면 부모에게 true/false 알려주기
  final ValueChanged<bool>? onLikeChanged;

  const ItemInfo({
    super.key,
    required this.category,
    required this.title,
    required this.location,
    required this.price,
    this.isLike = false,
    this.onLikeChanged, // ✅
  });

  @override
  State<ItemInfo> createState() => _ItemInfoState();
}

class _ItemInfoState extends State<ItemInfo> {
  late bool isLiked;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isLike;
  }

  void toggleIsLike() {
    setState(() {
      isLiked = !isLiked;
    });
    widget.onLikeChanged?.call(isLiked); // ✅ 부모에 알림
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widgetbackgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Row(
          children: [
            const Icon(Icons.photo),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: pointColorStrong,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on_sharp, size: 15),
                        const SizedBox(width: 5),
                        Text(
                          widget.location,
                          style: TextStyle(
                            color: pointColorWeak,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${widget.price} ₩ /day",
                      style: TextStyle(
                        color: pointColorWeak,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: Icon(isLiked ? Icons.star : Icons.star_border),
              iconSize: 30,
              color: pointColorWeak,
              onPressed: toggleIsLike,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ItemInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLike != widget.isLike) {
      isLiked = widget.isLike;
    }
  }
}
