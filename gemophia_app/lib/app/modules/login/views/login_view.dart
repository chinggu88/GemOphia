import 'dart:developer';

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

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _statusMessage = '이메일을 입력해주세요.';
      });
      return;
    }

    try {
      final res = await SupabaseService.to.login( _emailController.text.trim());
      
    } catch (e) {
      setState(() {
        _statusMessage = '알 수 없는 오류: $e';
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
      appBar: AppBar(title: const Text('로그인 (매직 링크)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일 주소'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _sendMagicLink,
              child: const Text('로그인 링크 보내기'),
            ),
            const SizedBox(height: 20),
            Text(_statusMessage),
          ],
        ),
      ),
    );
  }
}