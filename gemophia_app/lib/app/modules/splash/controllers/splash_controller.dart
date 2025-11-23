import 'package:get/get.dart';
import 'package:gemophia_app/app/services/supabase_service.dart';
import 'package:gemophia_app/app/routes/app_pages.dart';

class SplashController extends GetxController {
  static SplashController get to => Get.find();

  @override
  void onReady() {
    super.onReady();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // SupabaseService 초기화 대기
    while (SupabaseService.to.isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // 인증 상태 확인 후 적절한 화면으로 이동
    final user = SupabaseService.to.currentUser;

    if (user == null) {
      // 로그인 안 됨 → LOGIN 페이지
      Get.offAllNamed(Routes.LOGIN);
    } else {
      // 로그인 됨 → 커플 정보 확인 후 적절한 페이지로 이동
      await SupabaseService.to.checkCoupleAndNavigate(user.id);
    }
  }
}
