import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gemophia_app/app/services/supabase_service.dart';
import 'package:gemophia_app/app/routes/app_pages.dart';

class InviteController extends GetxController {
  static InviteController get to => Get.find();

  // 상태 관리
  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  // 커플 정보
  final _hasCoupleInfo = false.obs;
  bool get hasCoupleInfo => _hasCoupleInfo.value;
  set hasCoupleInfo(bool value) => _hasCoupleInfo.value = value;

  // 초대 코드
  final _inviteCode = ''.obs;
  String get inviteCode => _inviteCode.value;
  set inviteCode(String value) => _inviteCode.value = value;

  // 초대 URL
  final _inviteUrl = ''.obs;
  String get inviteUrl => _inviteUrl.value;
  set inviteUrl(String value) => _inviteUrl.value = value;

  // 초대받은 경우의 커플 정보
  final Rx<Map<String, dynamic>?> inviterCoupleInfo = Rx<Map<String, dynamic>?>(
    null,
  );

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// 초기화: 커플 정보 확인 및 초대 코드 처리
  Future<void> _initialize() async {
    try {
      isLoading = true;

      // 1. 현재 사용자 ID 가져오기
      final userId = SupabaseService.to.currentUser?.id;
      if (userId == null) {
        Get.snackbar('오류', '로그인이 필요합니다.');
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // 2. URL에서 초대 코드 확인
      print('asdf URL에서 초대 코드 확인 ${Get.parameters['invite_code']}');

      // 3. 커플 정보 확인
      final coupleData = await _checkCoupleInfo(userId);

      if (coupleData != null) {
        // 이미 커플 정보가 있음 -> HOME으로 이동
        hasCoupleInfo = true;
        Get.offAllNamed(Routes.HOME);
        return;
      }

      // 4. 커플 정보가 없는 경우
      hasCoupleInfo = false;

      if (inviteCode != null && inviteCode.isNotEmpty) {
        // 초대 코드가 있는 경우 -> 커플 정보 조회
        await _loadInviterInfo(inviteCode);
      } else {
        // 초대 코드가 없는 경우 -> 새로운 초대 코드 생성
        await _generateInviteCode(userId);
      }
    } catch (e) {
      Get.snackbar('오류', '초기화 중 오류가 발생했습니다: $e');
    } finally {
      isLoading = false;
    }
  }

  /// 커플 정보 확인
  Future<Map<String, dynamic>?> _checkCoupleInfo(String userId) async {
    try {
      // user1_id 또는 user2_id가 현재 사용자인 커플 찾기
      final couples = await SupabaseService.to.readWithFilter(
        table: 'couples',
        filters: {},
        columns: '*',
      );

      // 현재 사용자가 포함된 커플 찾기
      for (var couple in couples) {
        if (couple['user1_id'] == userId || couple['user2_id'] == userId) {
          return couple;
        }
      }

      return null;
    } catch (e) {
      // 커플 정보 확인 실패
      return null;
    }
  }

  /// 초대 코드 생성
  Future<void> _generateInviteCode(String userId) async {
    try {
      // 사용자 ID 기반으로 초대 코드 생성 (간단한 방식)
      final code = userId.substring(0, 8).toUpperCase();
      inviteCode = code;

      // 초대 URL 생성 (실제 앱의 딥링크 URL로 변경 필요)
      inviteUrl = 'gemophia://invite?invite_code=$code';
    } catch (e) {
      Get.snackbar('오류', '초대 코드 생성 실패: $e');
    }
  }

  /// 초대자 정보 로드
  Future<void> _loadInviterInfo(String inviterUserId) async {
    try {
      // 초대 코드(user_id 앞 8자리)로 초대자 찾기
      final allUsers = await SupabaseService.to.readAll(table: 'profiles');

      String? inviterId;
      for (var user in allUsers) {
        if (user['id'].toString().substring(0, 8).toUpperCase() ==
            inviterUserId.toUpperCase()) {
          inviterId = user['id'];
          break;
        }
      }

      if (inviterId == null) {
        Get.snackbar('오류', '유효하지 않은 초대 코드입니다.');
        inviteCode = '';
        await _generateInviteCode(SupabaseService.to.currentUser!.id);
        return;
      }

      // 초대자의 프로필 정보 가져오기
      final inviterProfile = await SupabaseService.to.readSingle(
        table: 'profiles',
        match: {'id': inviterId},
      );

      inviterCoupleInfo.value = inviterProfile;
      inviteCode = inviterUserId;
    } catch (e) {
      Get.snackbar('오류', '초대자 정보 로드 실패: $e');
    }
  }

  /// 초대 코드 복사
  void copyInviteUrl() {
    Clipboard.setData(ClipboardData(text: inviteUrl));
    Get.snackbar('성공', '초대 링크가 클립보드에 복사되었습니다!');
  }

  /// 커플 등록
  Future<void> registerCouple() async {
    try {
      isLoading = true;

      final userId = SupabaseService.to.currentUser?.id;
      if (userId == null) {
        Get.snackbar('오류', '로그인이 필요합니다.');
        return;
      }

      // inviterCoupleInfo에서 초대자 ID 가져오기
      final inviterId = inviterCoupleInfo.value?['id'];
      if (inviterId == null) {
        Get.snackbar('오류', '초대자 정보를 찾을 수 없습니다.');
        return;
      }

      // 커플 데이터 생성
      final coupleData = {
        'user1_id': inviterId,
        'user2_id': userId,
        'anniversary_date': DateTime.now().toIso8601String().split('T')[0],
        'status': 'active',
      };

      // 커플 정보 저장
      await SupabaseService.to.create(table: 'couples', data: coupleData);

      Get.snackbar('성공', '커플 등록이 완료되었습니다!');

      // HOME으로 이동
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar('오류', '커플 등록 실패: $e');
    } finally {
      isLoading = false;
    }
  }

  /// 초대 거절
  void declineInvite() async {
    // 초대 코드 제거하고 새로운 초대 코드 생성
    inviterCoupleInfo.value = null;
    inviteCode = '';
    await _generateInviteCode(SupabaseService.to.currentUser!.id);
  }
}
