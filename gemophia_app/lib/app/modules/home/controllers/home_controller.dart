import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find();

  // 현재 탭 인덱스
  final _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;
  set currentIndex(int value) => _currentIndex.value = value;

  void changeTab(int index) {
    currentIndex = index;
  }
}
