import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/loading_view.dart';
import '../controllers/auth_controller.dart';

class SplashPage extends GetView<AuthController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingView(message: 'Starting Aquacare CRM...');
        }
        return const LoadingView(message: 'Checking session...');
      }),
    );
  }
}
