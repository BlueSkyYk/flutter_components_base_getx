import 'package:flutter/material.dart';
import 'package:flutter_components_base_getx/base/base_controller.dart';
import 'package:flutter_components_base_getx/base/base_page.dart';
import 'package:get/get.dart';

/// 详情页控制器
/// 展示如何控制手势返回和页面返回结果
class DetailController extends BaseController {
  final formData = ''.obs;
  final hasUnsavedChanges = false.obs;

  @override
  void onPageInit() {
    super.onPageInit();
    print('📄 DetailController onPageInit');
  }

  @override
  void onPageShow() {
    super.onPageShow();
    print('📄 DetailController onPageShow');
  }

  @override
  void onPageHide() {
    super.onPageHide();
    print('📄 DetailController onPageHide');
  }

  @override
  void onPageDispose() {
    super.onPageDispose();
    print('📄 DetailController onPageDispose');
  }

  /// 处理返回事件
  @override
  void onPopInvokedWithResult(bool didPop, dynamic result) {
    super.onPopInvokedWithResult(didPop, result);
    print('📄 onPopInvokedWithResult - didPop: $didPop, result: $result');

    if (!didPop && hasUnsavedChanges.value) {
      // 如果有未保存的更改，显示确认对话框
      _showDiscardDialog();
    }
  }

  /// 表单内容变化
  void onFormChanged(String value) {
    formData.value = value;
    final hasChanges = value.isNotEmpty;

    // 根据是否有未保存的更改来控制返回行为
    if (hasChanges != hasUnsavedChanges.value) {
      hasUnsavedChanges.value = hasChanges;
      updateCanPop(!hasChanges); // 有更改时禁用直接返回
    }
  }

  /// 保存数据
  void saveData() {
    if (formData.value.isEmpty) {
      Get.snackbar('提示', '请输入内容');
      return;
    }

    print('💾 保存数据: ${formData.value}');
    Get.snackbar(
      '成功',
      '数据已保存',
      snackPosition: SnackPosition.BOTTOM,
    );

    // 保存后允许返回
    hasUnsavedChanges.value = false;
    updateCanPop(true);

    // 延迟返回，携带结果
    Future.delayed(const Duration(milliseconds: 500), () {
      Get.back(result: formData.value);
    });
  }

  /// 取消并返回
  void cancelAndBack() {
    if (hasUnsavedChanges.value) {
      _showDiscardDialog();
    } else {
      Get.back();
    }
  }

  /// 显示放弃更改对话框
  void _showDiscardDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('放弃更改？'),
        content: const Text('您有未保存的更改，确定要放弃吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // 关闭对话框
              hasUnsavedChanges.value = false;
              updateCanPop(true);
              Get.back(); // 返回上一页
            },
            child: const Text(
              '放弃',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

/// 详情页页面
class DetailPage extends BasePage<DetailController> {
  DetailPage({super.key}) : super(controller: DetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('详情页'),
        actions: [
          Obx(() {
            return controller.hasUnsavedChanges.value
                ? Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '未保存',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 说明卡片
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '演示功能',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('✅ 控制手势返回（canPop）'),
                    const Text('✅ 未保存时提示用户'),
                    const Text('✅ 返回结果到上一页'),
                    const Text('✅ PopScope 的使用'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 表单输入
            TextField(
              onChanged: controller.onFormChanged,
              decoration: const InputDecoration(
                labelText: '输入内容',
                hintText: '输入内容后将无法直接返回',
                border: OutlineInputBorder(),
                helperText: '输入内容后尝试手势返回或点击返回按钮',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // 操作按钮
            ElevatedButton.icon(
              onPressed: controller.saveData,
              icon: const Icon(Icons.save),
              label: const Text('保存并返回'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: controller.cancelAndBack,
              icon: const Icon(Icons.cancel),
              label: const Text('取消'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),

            // 状态显示
            Obx(() {
              return Card(
                color: controller.hasUnsavedChanges.value
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前状态',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: controller.hasUnsavedChanges.value
                              ? Colors.red.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.hasUnsavedChanges.value
                            ? '❌ canPop = false (禁用手势返回)'
                            : '✅ canPop = true (允许手势返回)',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '表单数据: ${controller.formData.value.isEmpty ? "空" : controller.formData.value}',
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
