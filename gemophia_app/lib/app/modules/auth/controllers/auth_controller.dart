import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  // 로그인 상태
  final _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;
  set isLoggedIn(bool value) => _isLoggedIn.value = value;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void login() {
    // TODO: Implement login logic
    isLoggedIn = true;
  }

  void logout() {
    // TODO: Implement logout logic
    isLoggedIn = false;
  }
}
