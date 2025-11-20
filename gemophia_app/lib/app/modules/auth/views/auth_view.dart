import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        centerTitle: true,
      ),
      body: Center(
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.isLoggedIn ? 'Logged In' : 'Logged Out',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.isLoggedIn
                    ? controller.logout
                    : controller.login,
                child: Text(
                  controller.isLoggedIn ? 'Logout' : 'Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
