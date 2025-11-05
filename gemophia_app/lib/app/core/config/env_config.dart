import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 설정을 관리하는 클래스
/// .env 파일에서 민감한 정보를 로드합니다
class EnvConfig {
  /// .env 파일 초기화
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  /// Supabase URL
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase Anonymous Key
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Gemini API Key
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// 환경 변수가 제대로 설정되었는지 검증
  static void validate() {
    final missingKeys = <String>[];

    if (supabaseUrl.isEmpty) missingKeys.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missingKeys.add('SUPABASE_ANON_KEY');

    if (missingKeys.isNotEmpty) {
      throw Exception(
        '다음 환경 변수가 설정되지 않았습니다: ${missingKeys.join(', ')}\n'
        '.env 파일을 확인해주세요.',
      );
    }
  }
}
