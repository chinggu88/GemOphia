import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';
import 'app/core/themes/app_theme.dart';
import 'app/core/config/env_config.dart';
import 'app/bindings/init_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한글 로케일 초기화
  await initializeDateFormatting('ko_KR', null);

  // 환경 변수 로드
  await EnvConfig.initialize();
  EnvConfig.validate();

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      child: GetMaterialApp(
        title: '퐁당',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialBinding: InitBinding(),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
