---
name: getx-controller
description: Flutter GetX Controller 생성 및 패턴 가이드. GetX 컨트롤러 작성, GetX 상태관리 코드 생성, obs 변수 선언, GetxController 클래스 작성 요청 시 사용. "GetX 컨트롤러 만들어줘", "GetX로 상태관리 해줘", "obs 변수 추가해줘" 등의 요청에 트리거됨.
---

# GetX Controller

Flutter GetX 패턴에 맞는 Controller를 생성한다.

## 워크플로우

1. Controller 필수 구조를 기반으로 클래스 생성
2. 필요한 변수는 변수 규칙에 따라 추가
3. 함수는 일반/API 함수 규칙에 따라 작성

## Controller 필수 구조

모든 GetxController는 아래 구조를 포함한다:

```dart
import 'dart:developer';
import 'package:get/get.dart';

class {ControllerName} extends GetxController {
  static {ControllerName} to = Get.find();

  // 1. 필수 변수
  final _loading = true.obs;

  bool get isLoading => _loading.value;
  set loading(bool value) => _loading.value = value;

  // 2. 생명주기 메서드
  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  // 3. Public methods
  Future<void> fetchData() async {
    try {
      loading = true;
      // fetchData 로직 추가
    } catch (e) {
      log('Failed to fetchData: ${e.toString()}');
    } finally {
      loading = false;
    }
  }
}
```

## 변수 규칙

타입별 obs 변수 선언 패턴:

```dart
// Bool
final _isLoading = false.obs;
bool get isLoading => _isLoading.value;
set isLoading(bool value) => _isLoading.value = value;

// String
final _message = ''.obs;
String get message => _message.value;
set message(String value) => _message.value = value;

// int
final _count = 0.obs;
int get count => _count.value;
set count(int value) => _count.value = value;

// double
final _price = 0.0.obs;
double get price => _price.value;
set price(double value) => _price.value = value;

// List<T>
final _users = <User>[].obs;
List<User> get users => _users.value;
set users(List<User> value) => _users.assignAll(value);

// Custom Object
final _user = User().obs;
User get user => _user.value;
set user(User value) => _user.value = value;

// Nullable DateTime
final _selectedDate = Rx<DateTime?>(null);
DateTime? get selectedDate => _selectedDate.value;
set selectedDate(DateTime? value) => _selectedDate.value = value;
```

## 함수 규칙

### 일반 함수

```dart
/// 함수 요약 설명
/// [a] - 파라미터 a 설명
/// [b] - 파라미터 b 설명
void functionName(String a, String b) {
  // 로직 구현
}
```

### API 함수

```dart
/// 함수 요약 설명
Future<void> fetchData() async {
  try {
    loading = true;

    List<Item> result = await ApiRepository.fetchItemsData();

    if (result.isNotEmpty) {
      log('API fetchData Response: ${result.toList(growable: false)}');
      items = result;
    }
  } catch (e) {
    log('Failed to fetch data: ${e.toString()}');
  } finally {
    loading = false;
  }
}
```