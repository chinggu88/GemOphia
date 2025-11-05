import 'package:get/get.dart';

class AuthController extends GetxController {
  final isLoggedIn = false.obs;

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
    isLoggedIn.value = true;
  }

  void logout() {
    // TODO: Implement logout logic
    isLoggedIn.value = false;
  }
}
