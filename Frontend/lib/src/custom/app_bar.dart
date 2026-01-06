import 'package:flutter/material.dart';
import 'package:sharing_items/const/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final TextEditingController? searchController;
  final bool showSearch;

  final ValueChanged<LatLng>? onLocateMe;
  final String? locationText;


  const CustomAppBar({
    super.key,
    required this.title,
    this.searchController,
    this.showSearch = false,
    this.onLocateMe,
    this.locationText,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: pointColorWeak,
      elevation: 0,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Center(
                    /// 가운데 부분 채우기
                    child: Text(
                      locationText ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "원하시는 물건을 검색해주세요.",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.location_on),
          color: Colors.white,
          tooltip: '위치 설정',
          onPressed: () async {
            //구글지도를 통해 위치설정 기능 구현하기
            try{
              //위치 서비스 활성화 여부 확인
              final serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if(!serviceEnabled){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("위치 서비스가 꺼져있습니다.")),
                );
                await Geolocator.openLocationSettings();
                return;
              }

              //권한 확인 및 요청
              LocationPermission permission = await Geolocator.checkPermission();
              if(permission == LocationPermission.denied){
                permission = await Geolocator.requestPermission();
              }
              if(permission == LocationPermission.denied){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("위치 권한이 거부되었습니다.")),
                );
                return;
              }
              if(permission == LocationPermission.deniedForever){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("설정에서 위치 권한을 허용해주세요.")),
                );
                await Geolocator.openAppSettings();
                return;
              }

              //현재 위치 가져오기
              final Position position = await Geolocator.getCurrentPosition(
                locationSettings: LocationSettings(
                  accuracy: LocationAccuracy.high,
                  timeLimit: const Duration(seconds: 6),
                ),
              ).onError((error, stackTrace) async {
                final last = await Geolocator.getLastKnownPosition();
                if(last != null) {
                  return Position(
                    latitude: last.latitude,
                    longitude: last.longitude,
                    timestamp: last.timestamp ?? DateTime.now(),
                    accuracy: last.accuracy,
                    altitude: last.altitude,
                    heading: last.heading,
                    speed: last.speed,
                    speedAccuracy: last.speedAccuracy,
                    altitudeAccuracy: last.altitudeAccuracy,
                    headingAccuracy: last.headingAccuracy,
                  );
                }
                throw error!;
              });

              final target = LatLng(position.latitude, position.longitude);

              //부모로 알림
              onLocateMe?.call(target);
            } catch (e){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('현재 위치를 가져오지 못했습니다.: $e')),
              );
            }
          },
        ),
      ],
    );
  }
}