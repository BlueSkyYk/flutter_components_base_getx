import 'package:flutter/material.dart';
import 'package:flutter_components_base_getx/component.dart';
import 'package:get/get.dart';

import 'pages/home_page.dart';
import 'services/user_service.dart';

void main() {
  // 初始化全局服务
  Get.put(UserService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Components Base GetX Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // 重要：必须添加 appRouteObserver 才能使生命周期正常工作
      navigatorObservers: [appRouteObserver],
      home: HomePage(key: const Key('home')),
      debugShowCheckedModeBanner: false,
    );
  }
}
