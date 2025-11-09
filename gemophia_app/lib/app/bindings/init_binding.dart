import 'package:get/get.dart';
import '../services/supabase_service.dart';

class InitBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SupabaseService>(
      SupabaseService(),
      permanent: true
    );
  }
}