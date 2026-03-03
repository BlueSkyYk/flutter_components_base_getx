import 'package:flutter/material.dart';
import 'package:flutter_components_base_getx/base/base_controller.dart';
import 'package:flutter_components_base_getx/base/base_item_controller.dart';
import 'package:flutter_components_base_getx/base/base_page.dart';
import 'package:get/get.dart';

/// 列表页控制器
class ListController extends BaseController {
  final items = <String>[].obs;

  @override
  void onPageInit() {
    super.onPageInit();
    print('📋 ListController onPageInit');

    // 初始化列表数据
    items.value = List.generate(20, (index) => 'Item ${index + 1}');
  }

  @override
  void onPageShow() {
    super.onPageShow();
    print('📋 ListController onPageShow');
  }

  @override
  void onPageHide() {
    super.onPageHide();
    print('📋 ListController onPageHide');
  }
}

/// 列表项控制器
/// 使用 BaseItemController 来管理列表项的可见性
class ListItemController extends BaseItemController {
  final String itemId;
  final counter = 0.obs;
  final isHighlighted = false.obs;

  ListItemController(this.itemId);

  @override
  void onPageInit() {
    super.onPageInit();
    print('   📌 ListItemController [$itemId] onPageInit');
  }

  @override
  void onPageShow() {
    super.onPageShow();
    print('   📌 ListItemController [$itemId] onPageShow - item 可见');
    // 可以在这里启动定时器、动画等
  }

  @override
  void onPageHide() {
    super.onPageHide();
    print('   📌 ListItemController [$itemId] onPageHide - item 不可见');
    // 可以在这里停止定时器、动画等
  }

  @override
  void onPageDispose() {
    super.onPageDispose();
    print('   📌 ListItemController [$itemId] onPageDispose');
  }

  void increment() {
    counter.value++;
  }

  void toggleHighlight() {
    isHighlighted.value = !isHighlighted.value;
  }
}

/// 列表页页面
class ListPage extends BasePage<ListController> {
  ListPage({super.key}) : super(controller: ListController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('列表页 (BaseItemController)'),
      ),
      body: Column(
        children: [
          // 说明卡片
          Card(
            margin: const EdgeInsets.all(16.0),
            color: Colors.purple.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'BaseItemController 说明',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '✅ 每个列表项都有独立的 Controller\n'
                    '✅ 使用 VisibilityDetector 检测可见性\n'
                    '✅ 只有可见的 item 才会触发 onPageShow\n'
                    '✅ 滚动时查看控制台日志',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // 列表
          Expanded(
            child: Obx(() {
              return ListView.builder(
                itemCount: controller.items.length,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return ListItemWidget(
                    key: Key(item),
                    itemId: item,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// 列表项 Widget
/// 使用 VisibilityDetector 检测可见性，并调用 updateItemShowStatus
class ListItemWidget extends StatefulWidget {
  final String itemId;

  const ListItemWidget({
    super.key,
    required this.itemId,
  });

  @override
  State<ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {
  late final ListItemController controller;

  @override
  void initState() {
    super.initState();
    // 为每个列表项创建独立的 controller
    controller = Get.put(
      ListItemController(widget.itemId),
      tag: widget.itemId,
    );
    controller.pageInit();
  }

  @override
  void dispose() {
    controller.pageDispose();
    Get.delete<ListItemController>(tag: widget.itemId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('visibility_${widget.itemId}'),
      onVisibilityChanged: (visibilityInfo) {
        // 当可见比例超过 10% 时认为可见
        final isVisible = visibilityInfo.visibleFraction > 0.1;
        controller.updateItemShowStatus(isVisible);
      },
      child: Obx(() {
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          color: controller.isHighlighted.value
              ? Colors.yellow.shade100
              : null,
          elevation: controller.isHighlighted.value ? 4 : 1,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: controller.itemShowing
                  ? Colors.green
                  : Colors.grey,
              child: Text(
                controller.itemShowing ? '👁️' : '⚫',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            title: Text(widget.itemId),
            subtitle: Text(
              controller.itemShowing
                  ? '✅ 当前可见 (计数: ${controller.counter.value})'
                  : '⚫ 当前不可见 (计数: ${controller.counter.value})',
              style: TextStyle(
                color: controller.itemShowing
                    ? Colors.green.shade700
                    : Colors.grey.shade600,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: controller.increment,
                  tooltip: '增加计数',
                ),
                IconButton(
                  icon: Icon(
                    controller.isHighlighted.value
                        ? Icons.star
                        : Icons.star_border,
                  ),
                  onPressed: controller.toggleHighlight,
                  tooltip: '高亮',
                  color: controller.isHighlighted.value
                      ? Colors.amber
                      : null,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

/// 可见性检测器
/// 简化版实现，实际项目中建议使用 visibility_detector 包
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<VisibilityInfo> onVisibilityChanged;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    // 简化实现：使用 LayoutBuilder 来检测
    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用 post-frame callback 检测可见性
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkVisibility();
        });
        return widget.child;
      },
    );
  }

  void _checkVisibility() {
    try {
      final renderObject = context.findRenderObject();
      if (renderObject != null && renderObject is RenderBox) {
        final position = renderObject.localToGlobal(Offset.zero);
        final size = renderObject.size;
        final screenHeight = MediaQuery.of(context).size.height;

        // 计算可见比例
        final top = position.dy;
        final bottom = position.dy + size.height;
        final visibleTop = top.clamp(0.0, screenHeight);
        final visibleBottom = bottom.clamp(0.0, screenHeight);
        final visibleHeight = (visibleBottom - visibleTop).clamp(0.0, size.height);
        final visibleFraction = size.height > 0 ? visibleHeight / size.height : 0.0;

        widget.onVisibilityChanged(
          VisibilityInfo(visibleFraction: visibleFraction),
        );
      }
    } catch (e) {
      // 忽略错误
    }
  }
}

/// 可见性信息
class VisibilityInfo {
  final double visibleFraction;

  VisibilityInfo({required this.visibleFraction});
}
