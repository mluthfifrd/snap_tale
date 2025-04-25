import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:snap_tale/data/api/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../story_controller.dart';

class AuthController extends GetxController {
  final ApiServices _authService = ApiServices();
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var name = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkToken();
  }

  Future<void> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString('name') ?? '';
    final token = await _authService.getToken();
    isAuthenticated.value = token != null && token.isNotEmpty;
  }

  void updateRouter() {
    if (isAuthenticated.value) {
      GoRouter.of(Get.context!).go('/home');
    } else {
      GoRouter.of(Get.context!).go('/login');
    }
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    isLoading(true);
    final result = await _authService.login(email, password);

    if (!result.error && result.loginResult != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', result.loginResult!.name);
      await _authService.saveToken(result.loginResult!.token);
      isAuthenticated.value = true;

      if (context.mounted) {
        name.value = result.loginResult!.name;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.message}, Welcome ${name.value}'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
        isLoading(false);
      }
    } else {
      isLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    isLoading(true);
    final result = await _authService.register(name, email, password);

    if (!result.error) {
      if (context.mounted) {
        context.go('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
        isLoading(false);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
        isLoading(false);
      }
      isLoading(false);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _authService.removeToken();
    Get.delete<StoryController>();
    isAuthenticated.value = false;
    if (context.mounted) {
      context.go('/login');
    }
  }
}
