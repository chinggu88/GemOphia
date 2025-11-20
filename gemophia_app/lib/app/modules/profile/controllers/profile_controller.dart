import 'package:get/get.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();

  // 사용자 이름
  final _userName = 'User Name'.obs;
  String get userName => _userName.value;
  set userName(String value) => _userName.value = value;

  // 사용자 이메일
  final _userEmail = 'user@example.com'.obs;
  String get userEmail => _userEmail.value;
  set userEmail(String value) => _userEmail.value = value;
}
