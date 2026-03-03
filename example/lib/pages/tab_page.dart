import 'package:flutter/material.dart';
import 'package:flutter_components_base_getx/base/base_controller.dart';
import 'package:flutter_components_base_getx/base/base_page.dart';
import 'package:flutter_components_base_getx/components/keep_alive_wrapper.dart';
import 'package:get/get.dart';

/// Tab 页面控制器
class TabPageController extends BaseController {
  final currentTabIndex = 0.obs;

  @override
  void onPageInit() {
    super.onPageInit();
    print('🔖 TabPageController onPageInit');
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}

/// Tab 页面
class TabPage extends BasePage<TabPageController> {
  TabPage({super.key}) : super(controller: TabPageController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tab 页面 (KeepAlive)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Tab 1'),
              Tab(icon: Icon(Icons.star), text: 'Tab 2'),
              Tab(icon: Icon(Icons.person), text: 'Tab 3'),
            ],
          ),
        ),
        body: Column(
          children: [
            // 说明卡片
            Card(
              margin: const EdgeInsets.all(16.0),
              color: Colors.teal.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.teal.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'KeepAliveWrapper 说明',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '✅ 使用 KeepAliveWrapper 保持 Tab 状态\n'
                      '✅ 切换 Tab 时不会重新构建\n'
                      '✅ 输入框内容和计数器会保持\n'
                      '✅ 适用于 TabBarView、PageView 等',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  KeepAliveWrapper(
                    child: TabContentWidget(
                      title: 'Tab 1 内容',
                      color: Colors.red.shade100,
                      icon: Icons.home,
                    ),
                  ),
                  KeepAliveWrapper(
                    child: TabContentWidget(
                      title: 'Tab 2 内容',
                      color: Colors.green.shade100,
                      icon: Icons.star,
                    ),
                  ),
                  KeepAliveWrapper(
                    child: TabContentWidget(
                      title: 'Tab 3 内容',
                      color: Colors.blue.shade100,
                      icon: Icons.person,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab 内容 Widget
class TabContentWidget extends StatefulWidget {
  final String title;
  final Color color;
  final IconData icon;

  const TabContentWidget({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
  });

  @override
  State<TabContentWidget> createState() => _TabContentWidgetState();
}

class _TabContentWidgetState extends State<TabContentWidget> {
  int counter = 0;
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('🎨 ${widget.title} - initState 被调用');
  }

  @override
  void dispose() {
    print('🎨 ${widget.title} - dispose 被调用');
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 ${widget.title} - build 被调用');

    return Container(
      color: widget.color,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 64, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // 计数器
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    '计数器（测试状态保持）',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$counter',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        counter++;
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('增加'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 输入框
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    '输入框（测试状态保持）',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: '输入内容后切换 Tab 再回来',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '提示：切换到其他 Tab 再回来，\n这里的内容和计数器会保持不变',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 构建次数提示
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.build, size: 20),
                const SizedBox(width: 8),
                Text(
                  '查看控制台的 build 日志',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
