import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gemophia_app/app/services/supabase_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Profile')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/test_model_m.jpg',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: double.infinity,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                    child: Image.asset(
                      'assets/images/test_model_f.jpg',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: Get.size.width,
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Iksun',
                        // SupabaseService.to.user.email!.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        runSpacing: 5,
                        children: [
                          _tagsChip('Flutter'),
                          _tagsChip('Dart'),
                          _tagsChip('GetX'),
                          _tagsChip('Firebase'),
                          _tagsChip('Supabase'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: Get.size.width,
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'joshua',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Wrap(
                        runSpacing: 5,
                        // spacing: 3,
                        children: [
                          _tagsChip('AI'),
                          _tagsChip('Stt'),
                          _tagsChip('Nlp'),
                          _tagsChip('ML'),
                          _tagsChip('Python'),
                          _tagsChip('Flask'),
                          _tagsChip('Django'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tagsChip(String tag) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40), // 다크 그레이 배경
        borderRadius: BorderRadius.circular(10.r), // 둥근 모서리
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
// class ProfileView extends GetView<ProfileController> {
//   const ProfileView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Stack(
//           children: [
//             // 왼쪽 아래에서 오른쪽 위로 올라가는 대각선(왼쪽 영역)
//             Positioned(
//               top: 0,
//               right: 0,
//               left: 0,
//               bottom: Get.size.height * 0.3,
//               child: ClipPath(
//                 clipper: _LeftDiagonalClipper(),
//                 child: Image.asset(
//                   'assets/images/test_model_m.jpg',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),

//             // 오른쪽 위에서 왼쪽 아래로 내려오는 대각선(오른쪽 영역)
//             Positioned(
//               top: Get.size.height * 0.3,
//               right: 0,
//               left: 0,
//               bottom: 0,
//               child: ClipPath(
//                 clipper: _RightDiagonalClipper(),
//                 child: Image.asset(
//                   'assets/images/test_model_f.jpg',
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),

//             // 경계에 얇은 라인(선택사항)
//             // Positioned.fill(
//             //   child: CustomPaint(painter: _DiagonalBorderPainter()),
//             // ),

//             // 예시: 각 영역을 탭했을 때 반응
//             // Positioned.fill(
//             //   child: GestureDetector(
//             //     behavior: HitTestBehavior.translucent,
//             //     onTapUp: (details) {
//             //       final tap = details.localPosition;
//             //       final width = constraints.maxWidth;
//             //       final height = constraints.maxHeight;
//             //       // 간단한 판별: 터치가 대각선 위쪽(오른쪽 영역)인지 아래쪽(왼쪽 영역)인지
//             //       final diagY = height - (height / width) * tap.dx;
//             //       final isRightRegion = tap.dy < diagY;

//             //       ScaffoldMessenger.of(context).showSnackBar(
//             //         SnackBar(
//             //           content: Text(isRightRegion ? '오른쪽 영역 탭됨' : '왼쪽 영역 탭됨'),
//             //           duration: const Duration(milliseconds: 600),
//             //         ),
//             //       );
//             //     },
//             //   ),
//             // ),
//           ],
//         );
//       },
//     );
//   }
// }

// /// 왼쪽 영역을 자르는 클리퍼 (왼쪽 아래에서 오른쪽 위로 가는 선 기준)
// class _LeftDiagonalClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final Path path = Path();
//     // 왼쪽 아래 -> 왼쪽 상단 -> 오른쪽 상단 -> 대각선으로 돌아오기
//     path.moveTo(0, size.height);
//     path.lineTo(0, 0);
//     path.lineTo(size.width, 0);
//     // 대각선: 오른쪽 상단에서 오른쪽 하단으로 내려오지 않고
//     // 화면 오른쪽 끝에서 대각선에 맞춰 내려오는 점을 계산
//     path.lineTo(size.width, size.height - (size.height * 0.3));
//     // 대각선 직선을 그려서 왼쪽 아래로 연결
//     path.lineTo(0, size.height);
//     path.close();
//     // 위 경로는 기본 직사각형이므로, 실제 대각선은 아래에서 그려진 경계선으로 처리합니다.
//     // 대신 여기서는 단순히 전체를 채운 후 다른 클리퍼와 겹치게 해서 보이는 효과를 냅니다.
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
// }

// /// 오른쪽 영역을 자르는 클리퍼
// class _RightDiagonalClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     final Path path = Path();
//     // 오른쪽 상단부터 대각선으로 왼쪽 하단까지 연결되는 경로
//     path.moveTo(size.width, size.height);
//     path.lineTo(size.width, size.height * 0.2);
//     path.lineTo(0, size.height * 0.5);
//     path.lineTo(0, size.height - (size.height * 0.0));
//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
// }

// /// 대각선 경계선을 그려주는 페인터(중앙 선)
// class _DiagonalBorderPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint =
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 2.0
//           ..color = Colors.white.withOpacity(0.9)
//           ..strokeCap = StrokeCap.round;

//     // 왼쪽 하단 -> 오른쪽 상단 방향의 대각선
//     final p1 = Offset(0, size.height * 0.7);
//     final p2 = Offset(size.width, size.height * 0.3);

//     canvas.drawLine(p1, p2, paint);

//     // 얇은 그림자 느낌을 위해 연한 어두운 선을 약간 오프셋해서 그림자처럼 그림
//     final shadow =
//         Paint()
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 6.0
//           ..color = Colors.black.withOpacity(0.15)
//           ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

//     canvas.drawLine(p1.translate(2, -2), p2.translate(-2, 2), shadow);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
