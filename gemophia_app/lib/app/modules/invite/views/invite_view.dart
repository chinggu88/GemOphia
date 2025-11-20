import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invite_controller.dart';

class InviteView extends GetView<InviteController> {
  const InviteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('커플 초대'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 초대받은 경우 (초대자 정보가 있을 때)
        if (controller.inviterCoupleInfo.value != null) {
          return _buildAcceptInviteView(context);
        }

        // 초대 코드를 생성하는 경우
        return _buildCreateInviteView(context);
      }),
    );
  }

  /// 초대 코드 생성 화면
  Widget _buildCreateInviteView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // 아이콘
          Icon(
            Icons.favorite,
            size: 80,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 24),
          // 제목
          const Text(
            '커플을 초대해주세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // 설명
          Text(
            '아래 초대 링크를 상대방에게 공유하면\n함께 앱을 사용할 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 48),
          // 초대 코드 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Text(
                    '초대 코드',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text(
                        controller.inviteCode,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      )),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    '초대 링크',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          controller.inviteUrl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 링크 복사 버튼
          ElevatedButton.icon(
            onPressed: controller.copyInviteUrl,
            icon: const Icon(Icons.copy),
            label: const Text('초대 링크 복사'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 안내 메시지
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '상대방이 초대 링크를 통해 접속하면\n자동으로 커플 연결이 완료됩니다',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 초대 수락 화면
  Widget _buildAcceptInviteView(BuildContext context) {
    final inviterInfo = controller.inviterCoupleInfo.value!;
    final nickname = inviterInfo['nickname'] ?? '사용자';
    final avatarUrl = inviterInfo['avatar_url'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          // 프로필 이미지
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          // 초대 메시지
          Text(
            '$nickname님이',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '커플 초대를 보냈어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '함께 앱을 사용하시겠어요?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 48),
          // 초대자 정보 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildInfoRow('닉네임', nickname),
                  if (inviterInfo['bio'] != null) ...[
                    const SizedBox(height: 16),
                    _buildInfoRow('소개', inviterInfo['bio']),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // 수락 버튼
          ElevatedButton(
            onPressed: controller.registerCouple,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text(
              '초대 수락하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 거절 버튼
          OutlinedButton(
            onPressed: controller.declineInvite,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '거절하고 내 초대 코드 만들기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
