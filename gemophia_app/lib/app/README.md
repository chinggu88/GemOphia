# GetX MVC 폴더 구조

이 프로젝트는 GetX 패키지를 사용한 MVC(Model-View-Controller) 패턴으로 구성되어 있습니다.

## 폴더 구조

```
lib/
├── app/
│   ├── modules/                    # 기능별 모듈
│   │   ├── home/                   # Home 모듈 예시
│   │   │   ├── controllers/        # 비즈니스 로직
│   │   │   │   └── home_controller.dart
│   │   │   ├── views/              # UI 화면
│   │   │   │   └── home_view.dart
│   │   │   └── bindings/           # 의존성 주입
│   │   │       └── home_binding.dart
│   │   └── auth/                   # Auth 모듈 예시
│   │       ├── controllers/
│   │       │   └── auth_controller.dart
│   │       ├── views/
│   │       │   └── auth_view.dart
│   │       └── bindings/
│   │           └── auth_binding.dart
│   │
│   ├── data/                       # 데이터 레이어
│   │   ├── models/                 # 데이터 모델
│   │   │   └── user_model.dart
│   │   ├── providers/              # API 통신
│   │   │   └── api_provider.dart
│   │   └── repositories/           # 데이터 저장소
│   │       └── user_repository.dart
│   │
│   ├── routes/                     # 라우팅
│   │   ├── app_pages.dart          # 페이지 정의
│   │   └── app_routes.dart         # 라우트 경로
│   │
│   ├── core/                       # 핵심 기능
│   │   ├── themes/                 # 테마 설정
│   │   │   └── app_theme.dart
│   │   ├── values/                 # 상수 값
│   │   │   ├── app_colors.dart
│   │   │   └── app_strings.dart
│   │   └── utils/                  # 유틸리티
│   │       └── helpers.dart
│   │
│   └── global_widgets/             # 공통 위젯
│       ├── custom_button.dart
│       └── custom_text_field.dart
│
└── main.dart                       # 앱 진입점
```

## 각 폴더 설명

### 📁 modules/
- 각 기능별로 독립적인 모듈을 구성합니다
- 각 모듈은 MVC 패턴을 따릅니다:
  - **controllers/**: 비즈니스 로직과 상태 관리
  - **views/**: UI 구성 요소
  - **bindings/**: 의존성 주입 및 초기화

### 📁 data/
- **models/**: 데이터 구조를 정의하는 클래스
- **providers/**: API 호출 및 외부 데이터 소스 통신
- **repositories/**: Provider와 Controller 사이의 중간 계층, 데이터 로직 처리

### 📁 routes/
- **app_pages.dart**: 모든 페이지와 바인딩을 정의
- **app_routes.dart**: 라우트 경로 상수 정의

### 📁 core/
- **themes/**: 앱 전체 테마 설정
- **values/**: 색상, 문자열 등 앱 전체에서 사용하는 상수
- **utils/**: 헬퍼 함수 및 유틸리티

### 📁 global_widgets/
- 앱 전체에서 재사용되는 공통 위젯

## 새로운 모듈 생성 방법

1. `app/modules/` 폴더에 새 모듈 폴더 생성
2. 하위에 `controllers/`, `views/`, `bindings/` 폴더 생성
3. 각각 컨트롤러, 뷰, 바인딩 파일 생성
4. `app/routes/app_routes.dart`에 라우트 추가
5. `app/routes/app_pages.dart`에 GetPage 추가

### 예시: Profile 모듈 생성

```bash
mkdir -p app/modules/profile/{controllers,views,bindings}
```

```dart
// app/modules/profile/controllers/profile_controller.dart
import 'package:get/get.dart';

class ProfileController extends GetxController {
  // 로직 구현
}

// app/modules/profile/views/profile_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Container(),
    );
  }
}

// app/modules/profile/bindings/profile_binding.dart
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
```

## GetX 주요 기능

### 1. 상태 관리
```dart
// Observable 변수 선언
final count = 0.obs;

// UI에서 사용
Obx(() => Text('${controller.count.value}'))
```

### 2. 라우팅
```dart
// 페이지 이동
Get.to(() => NextPage());
Get.toNamed('/profile');

// 뒤로가기
Get.back();

// 모든 페이지 제거 후 이동
Get.offAll(() => HomePage());
```

### 3. 의존성 주입
```dart
// Binding에서 주입
Get.lazyPut<Controller>(() => Controller());
Get.put<Controller>(Controller());

// 컨트롤러 찾기
final controller = Get.find<Controller>();
```

### 4. 스낵바/다이얼로그
```dart
// 스낵바
Get.snackbar('제목', '메시지');

// 다이얼로그
Get.dialog(AlertDialog(...));

// 바텀시트
Get.bottomSheet(Container(...));
```

## 사용 예시

main.dart를 다음과 같이 수정하여 GetX를 사용할 수 있습니다:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/core/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GemOphia',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## 참고 자료

- [GetX 공식 문서](https://pub.dev/packages/get)
- [GetX Pattern](https://github.com/kauemurakami/getx_pattern)
