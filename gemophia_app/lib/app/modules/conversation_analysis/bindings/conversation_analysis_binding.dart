import 'package:get/get.dart';
import '../controllers/conversation_analysis_controller.dart';

class ConversationAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationAnalysisController>(
      () => ConversationAnalysisController(),
    );
  }
}
