# GetX Controller 규칙 (GetX Patterns)
## 설명 
1. 최소한의 구조는 Getx Controller 필수 구조를 항목 무조건 포함한다.
2. 추가적인 정보가 필요한 경우 ##변수규칙, ##함수규칙을 참고하여 소스를 만든다.
3. 변수명의 규칙은 
## Controller 필수구조.
```dart
import 'dart:developer';
import 'package:get/get.dart';

class {controllerName} extends GetxController {
  static {controllerName} to = Get.find();

  // 1. 필수 변수
  final _loading = true.obs;

  /// 로딩 유무
  bool get isLoading => _loading.value;
  set loading(bool value) => _loading.value = value;

  // 2. 생명주기 메서드
  @override
  void onInit() {
    super.onInit();
    featchdata();
  }

  // 3. Public methods
  Future<void> featchdata() async {
    try {
      loading = true;
      // featchdata 로직 추가
    } catch (e) {
      log('Failed to featchdata: ${e.toString()}');
    } finally {
      loading = false;
    }
  }
}
```

## 변수 규칙.
```dart
  // Bool 타입
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;
  
  // String 타입
  final _message = ''.obs;
  String get message => _message.value;
  set message(String value) => _message.value = value;
  
  // int 타입
  final _count = 0.obs;
  int get count => _count.value;
  set count(int value) => _count.value = value;
  
  // double 타입
  final _price = 0.0.obs;
  double get price => _price.value;
  set price(double value) => _price.value = value;
  
  // List Custom Object 타입
  final _users = <User>[].obs;
  List<User> get users => _users.value;
  set users(List<User> value) => _users.assignAll(value);
  
  
  // Custom Object 타입
  final _user = <User>().obs;
  User get user => _user.value;
  set user(User value) => _user.value = value;
  
  // DateTime 타입
  final _selectedDate = Rx<DateTime?>(null);
  DateTime? get selectedDate => _selectedDate.value;
  set selectedDate(DateTime? value) => _selectedDate.value = value;
```
## 일반 함수 규칙
```dart
///함수 요약 설명
///파라미터 설명
/// a - 설명
/// b - 설명
void functionName(String a, String b) {
  ///로직의 전체적인 설명
}
```
## api 함수 규칙
```dart
///함수 요약 설명
Future<void> fetchData() async {
  ///로직의 전체적인 설명
    try {
      loading = true;

      List<Item> result = await ApiRepository.fetchItemssData();

      if (result.isNotEmpty) {
        log('API fetchRootData Response: ${result.toList(growable: false)}');
        items = result;
      }
    } catch (e) {
      log('Failed to fetch data: ${e.toString()}');
    } finally {
      loading = false;
    }
  }
```