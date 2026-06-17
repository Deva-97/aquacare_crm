import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/di/app_bindings.dart';
import '../core/routes/app_pages.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';

class AquacareApp extends StatelessWidget {
  const AquacareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Aquacare CRM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      initialBinding: AppBinding(),
      getPages: AppPages.pages,
    );
  }
}
