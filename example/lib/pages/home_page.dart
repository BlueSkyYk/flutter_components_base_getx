import 'package:flutter/material.dart';
import 'package:flutter_components_base_getx/base/base_controller.dart';
import 'package:flutter_components_base_getx/base/base_page.dart';
import 'package:get/get.dart';

import '../services/user_service.dart';
import 'detail_page.dart';
import 'list_page.dart';
import 'tab_page.dart';

/// 主页控制器
class HomeController extends BaseController {
  final UserService userService = Get.find<UserService>();

  // 页面状态
  final counter = 0.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🏠 HomeController onInit');

    // 使用 ListenerMixin 监听 UserService 的数据变化
    listen(userService.userNameModel.listener, (value) {
      print('🏠 Home 页面收到用户名变化通知: $value');
    });
  }

  @override
  void onPageInit() {
    super.onPageInit();
    print('🏠 HomeController onPageInit - 页面初始化（仅一次）');
  }

  @override
  void onPageShow() {
    super.onPageShow();
    print('🏠 HomeController onPageShow - 页面显示（可能多次）');
    print('   - 当前可见状态: $isVisible');
    print('   - 应用前台状态: 前台');
  }

  @override
  void onPageHide() {
    super.onPageHide();
    print('🏠 HomeController onPageHide - 页面隐藏');
    print('   - 原因: 跳转到其他页面或应用进入后台');
  }

  @override
  void onPageDispose() {
    super.onPageDispose();
    print('🏠 HomeController onPageDispose - 页面销毁');
  }

  @override
  void onPopInvokedWithResult(bool didPop, dynamic result) {
    super.onPopInvokedWithResult(didPop, result);
    if (result != null) {
      print('🏠 收到返回结果: $result');
      Get.snackbar('返回结果', result.toString());
    }
  }

  /// 增加计数器
  void increment() {
    counter.value++;
  }

  /// 加载用户数据
  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      await userService.loadUserData();
      Get.snackbar(
        '成功',
        '用户数据加载完成',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载失败: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 跳转到详情页
  void goToDetail() async {
    // 演示如何在跳转时禁用手势返回
    // updateCanPop(false);

    final result = await Get.to(() => DetailPage());
    if (result != null) {
      print('📥 从详情页返回，结果: $result');
    }

    // updateCanPop(true);
  }

  /// 跳转到列表页
  void goToList() {
    Get.to(() => ListPage());
  }

  /// 跳转到 Tab 页面
  void goToTabPage() {
    Get.to(() => TabPage());
  }

  @override
  void onClose() {
    print('🏠 HomeController onClose');
    super.onClose();
  }
}

/// 主页页面
class HomePage extends BasePage<HomeController> {
  HomePage({super.key}) : super(controller: HomeController());

  @override
  void initPage() {
    super.initPage();
    print('🏠 HomePage initPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Components Base GetX'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 用户信息卡片
            _buildUserInfoCard(),
            const SizedBox(height: 16),

            // 计数器卡片
            _buildCounterCard(),
            const SizedBox(height: 16),

            // 功能按钮组
            _buildActionButtons(),
            const SizedBox(height: 16),

            // 生命周期说明
            _buildLifecycleInfo(),
          ],
        ),
      ),
    );
  }

  /// 用户信息卡片
  Widget _buildUserInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '用户信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final userService = controller.userService;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('👤 用户名: ${userService.userName}'),
                  const SizedBox(height: 8),
                  Text('🎂 年龄: ${userService.userAge}'),
                  const SizedBox(height: 8),
                  Text('🏷️ 标签: ${userService.tags.join(', ')}'),
                ],
              );
            }),
            const SizedBox(height: 12),
            Obx(() {
              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: controller.loadUserData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('加载用户数据'),
                    );
            }),
          ],
        ),
      ),
    );
  }

  /// 计数器卡片
  Widget _buildCounterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              '计数器示例',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              return Text(
                '${controller.counter.value}',
                style: Theme.of(Get.context!).textTheme.displayLarge,
              );
            }),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: controller.increment,
              icon: const Icon(Icons.add),
              label: const Text('增加'),
            ),
          ],
        ),
      ),
    );
  }

  /// 功能按钮组
  Widget _buildActionButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '页面导航',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: controller.goToDetail,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('跳转到详情页'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: controller.goToList,
              icon: const Icon(Icons.list),
              label: const Text('跳转到列表页 (BaseItemController)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: controller.goToTabPage,
              icon: const Icon(Icons.tab),
              label: const Text('跳转到 Tab 页面 (KeepAlive)'),
            ),
          ],
        ),
      ),
    );
  }

  /// 生命周期说明
  Widget _buildLifecycleInfo() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  '生命周期说明',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('✅ onPageInit: 页面初始化（仅一次）'),
            const SizedBox(height: 4),
            const Text('✅ onPageShow: 页面显示（可多次，包括从后台返回）'),
            const SizedBox(height: 4),
            const Text('✅ onPageHide: 页面隐藏（跳转或进入后台）'),
            const SizedBox(height: 4),
            const Text('✅ onPageDispose: 页面销毁'),
            const SizedBox(height: 12),
            Text(
              '💡 提示：查看控制台可以看到完整的生命周期日志',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    print('🏠 HomePage dispose');
    super.dispose();
  }
}
