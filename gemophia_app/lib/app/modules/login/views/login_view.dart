import 'package:flutter/material.dart';
import 'package:gemophia_app/app/services/supabase_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  String _statusMessage = '';
  bool _isLoading = false;

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _statusMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final res = await SupabaseService.to.login(_emailController.text.trim());
      setState(() {
        _statusMessage = '로그인 링크가 이메일로 전송되었습니다.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '알 수 없는 오류: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA), // Streamlit 배경색
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고/타이틀 섹션
                _buildHeader(),
                const SizedBox(height: 48),

                // 로그인 카드
                _buildLoginCard(),
                const SizedBox(height: 24),

                // 상태 메시지
                if (_statusMessage.isNotEmpty) _buildStatusMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 앱 아이콘/로고 영역
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF9D4EDD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.favorite,
            size: 64,
            color: Color(0xFF9D4EDD),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '퐁당',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: Colors.grey[900],
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '관계를 더 특별하게',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0068C9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.mail_outline,
                  color: Color(0xFF0068C9),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '이메일로 로그인',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '매직 링크를 이메일로 받아보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // 이메일 입력 필드
          Text(
            '이메일 주소',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'your@email.com',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0xFFF0F2F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF0068C9),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[900],
            ),
          ),
          const SizedBox(height: 24),

          // 로그인 버튼
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendMagicLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0068C9),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '로그인 링크 받기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    final isError = _statusMessage.contains('오류');
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFF4B4B).withOpacity(0.1)
            : const Color(0xFF21C073).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError
              ? const Color(0xFFFF4B4B).withOpacity(0.3)
              : const Color(0xFF21C073).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: isError ? const Color(0xFFFF4B4B) : const Color(0xFF21C073),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 14,
                color: isError ? const Color(0xFFFF4B4B) : const Color(0xFF21C073),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}