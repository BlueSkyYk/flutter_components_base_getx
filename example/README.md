# Flutter Components Base GetX - 示例应用

这是一个完整的示例应用，展示如何使用 `flutter_components_base_getx` 包的各种功能。

## 🚀 快速开始

### 安装依赖

```bash
flutter pub get
```

### 运行示例

```bash
flutter run
```

## 📱 示例页面说明

### 1. 主页 (HomePage)

**文件**: `lib/pages/home_page.dart`

**展示功能**:
- ✅ `BaseController` 的基本使用
- ✅ 页面生命周期钩子（onPageInit、onPageShow、onPageHide、onPageDispose）
- ✅ 与 `BaseService` 的响应式数据交互
- ✅ `ListenerMixin` 的使用
- ✅ 页面跳转和导航

**核心代码**:
```dart
class HomeController extends BaseController {
  @override
  void onPageShow() {
    super.onPageShow();
    print('🏠 页面显示');
  }
}

class HomePage extends BasePage<HomeController> {
  HomePage({super.key}) : super(controller: HomeController());
}
```

**学习要点**:
- 如何创建 BasePage 和 BaseController
- 生命周期钩子的调用时机
- 如何监听 Service 中的数据变化

---

### 2. 详情页 (DetailPage)

**文件**: `lib/pages/detail_page.dart`

**展示功能**:
- ✅ 控制手势返回（`canPop` / `updateCanPop`）
- ✅ PopScope 的使用
- ✅ 未保存提示对话框
- ✅ 返回结果到上一页（`onPopInvokedWithResult`）
- ✅ 表单状态管理

**核心代码**:
```dart
// 控制是否允许返回
void onFormChanged(String value) {
  final hasChanges = value.isNotEmpty;
  updateCanPop(!hasChanges); // 有更改时禁用直接返回
}

// 处理返回事件
@override
void onPopInvokedWithResult(bool didPop, dynamic result) {
  if (!didPop && hasUnsavedChanges.value) {
    _showDiscardDialog();
  }
}
```

**学习要点**:
- 如何动态控制页面返回行为
- 如何在返回前弹出确认对话框
- 如何传递返回结果

**测试建议**:
1. 在输入框输入内容
2. 尝试手势返回或点击返回按钮
3. 观察弹出的确认对话框
4. 点击"保存并返回"，在主页查看返回结果

---

### 3. 列表页 (ListPage)

**文件**: `lib/pages/list_page.dart`

**展示功能**:
- ✅ `BaseItemController` 的使用
- ✅ 列表项的可见性检测
- ✅ 每个列表项独立的 Controller 和生命周期
- ✅ 滚动时动态管理生命周期
- ✅ 性能优化（只有可见的 item 才处于活跃状态）

**核心代码**:
```dart
class ListItemController extends BaseItemController {
  @override
  void onPageShow() {
    super.onPageShow();
    print('列表项可见');
    // 启动动画、加载数据等
  }
}

// 使用 VisibilityDetector 检测可见性
VisibilityDetector(
  onVisibilityChanged: (info) {
    final isVisible = info.visibleFraction > 0.1;
    controller.updateItemShowStatus(isVisible);
  },
  child: ListItemWidget(),
)
```

**学习要点**:
- BaseItemController 与 BaseController 的区别
- 如何实现列表项的可见性检测
- 如何为每个列表项创建独立的 Controller

**测试建议**:
1. 滚动列表，观察控制台输出
2. 注意只有可见的列表项会输出 `onPageShow`
3. 滚动出视野后会输出 `onPageHide`
4. 点击"增加计数"和"高亮"按钮测试交互

---

### 4. Tab 页面 (TabPage)

**文件**: `lib/pages/tab_page.dart`

**展示功能**:
- ✅ `KeepAliveWrapper` 的使用
- ✅ 保持 Tab 状态不被销毁
- ✅ TabBarView 中的状态保持
- ✅ 输入框和计数器状态演示

**核心代码**:
```dart
TabBarView(
  children: [
    KeepAliveWrapper(
      child: TabContentWidget(title: 'Tab 1'),
    ),
    KeepAliveWrapper(
      child: TabContentWidget(title: 'Tab 2'),
    ),
  ],
)
```

**学习要点**:
- 什么时候需要使用 KeepAliveWrapper
- 如何保持 Tab 的状态
- build 方法的调用次数（查看控制台）

**测试建议**:
1. 在 Tab 1 中输入内容并增加计数
2. 切换到 Tab 2
3. 再切换回 Tab 1
4. 观察内容和计数器是否保持
5. 查看控制台的 build 日志

---

### 5. 用户服务 (UserService)

**文件**: `lib/services/user_service.dart`

**展示功能**:
- ✅ `BaseService` 的使用
- ✅ `ListenableDataModel` 封装响应式数据
- ✅ `ListenerMixin` 监听数据变化
- ✅ 全局服务的创建和使用

**核心代码**:
```dart
class UserService extends BaseService {
  final _userName = Rx<String>('访客');

  // 通过 ListenableDataModel 暴露
  ListenableDataModel<String> get userNameModel =>
      ListenableDataModel(_userName);

  // 使用 ListenerMixin 监听
  @override
  void onInit() {
    super.onInit();
    listen(_userName, (value) {
      print('用户名变化: $value');
    });
  }
}
```

**学习要点**:
- 如何创建全局服务
- 为什么要用 ListenableDataModel 封装
- 如何在 Controller 中监听 Service 的数据

---

## 🎯 核心功能演示

### 1. 生命周期管理

在各个页面中，查看控制台输出，可以看到完整的生命周期流程：

```
🏠 HomeController onInit
🏠 HomeController onPageInit - 页面初始化（仅一次）
🏠 HomeController onPageShow - 页面显示（可能多次）
[切换到其他页面]
🏠 HomeController onPageHide - 页面隐藏
[返回]
🏠 HomeController onPageShow - 页面显示（可能多次）
```

**测试步骤**:
1. 打开应用，观察主页的生命周期
2. 跳转到详情页，观察两个页面的生命周期
3. 返回主页，观察生命周期
4. 按 Home 键让应用进入后台，观察 `onPageHide`
5. 切回应用，观察 `onPageShow`

### 2. 手势返回控制

在详情页输入内容后：
1. 尝试手势返回 - 会被拦截
2. 会弹出确认对话框
3. 保存后才能返回

### 3. 列表项生命周期

在列表页滚动时：
1. 查看控制台输出
2. 只有可见的列表项会输出 `onPageShow`
3. 不可见的会输出 `onPageHide`
4. 绿色圆点表示可见，灰色表示不可见

### 4. Tab 状态保持

在 Tab 页面：
1. 在 Tab 1 中输入内容和增加计数
2. 切换到 Tab 2
3. 再切换回 Tab 1 - 内容和计数器都保持不变
4. 查看控制台，观察 build 方法的调用次数

---

## 📚 学习路径建议

### 新手入门
1. 从 **home_page.dart** 开始，理解基础用法
2. 查看控制台日志，理解生命周期
3. 尝试修改代码，观察变化

### 进阶学习
1. 学习 **detail_page.dart** 的手势返回控制
2. 理解 **user_service.dart** 的服务模式
3. 掌握 **list_page.dart** 的列表优化

### 高级应用
1. 研究 **tab_page.dart** 的状态保持
2. 自己实现一个带生命周期的页面
3. 结合实际项目需求进行改造

---

## 💡 代码结构

```
example/
├── lib/
│   ├── main.dart                 # 应用入口
│   ├── pages/
│   │   ├── home_page.dart        # 主页（基础示例）
│   │   ├── detail_page.dart      # 详情页（手势返回）
│   │   ├── list_page.dart        # 列表页（BaseItemController）
│   │   └── tab_page.dart         # Tab 页（KeepAlive）
│   └── services/
│       └── user_service.dart     # 用户服务（BaseService）
└── test/
    └── app_route_observer_test.dart  # 测试示例
```

---

## 🔍 调试技巧

### 1. 查看生命周期日志
所有生命周期事件都会输出到控制台，带有表情符号便于识别：
- 🏠 主页
- 📄 详情页
- 📋 列表页
- 🎨 Tab 页面
- 📌 列表项

### 2. 测试前后台切换
- 使用 Home 键或多任务切换测试 `onPageShow`/`onPageHide`
- 观察哪些场景会触发生命周期

### 3. 测试页面跳转
- 观察不同场景下的生命周期调用顺序
- A → B → 返回 A，观察完整流程

### 4. 测试列表滚动
- 在列表页滚动查看 item 的生命周期
- 观察绿色/灰色圆点的变化

---

## ❓ 常见问题

### Q: 为什么生命周期没有被调用？
A: 确保在 `main.dart` 中添加了 `navigatorObservers: [appRouteObserver]`

### Q: 如何测试前后台切换？
A: 在模拟器中按 Home 键，或在手机上切换到其他应用

### Q: 列表页的可见性检测原理是什么？
A: 使用 VisibilityDetector（示例中简化实现）检测 Widget 的可见比例

### Q: KeepAliveWrapper 和 BaseItemController 的区别？
A:
- KeepAliveWrapper: 保持 Widget 不被销毁
- BaseItemController: 管理 item 的显示/隐藏状态

---

## 🎓 扩展练习

尝试自己实现以下功能，巩固学习：

1. **练习1**: 创建一个新页面，实现登录表单，输入内容后禁用返回
2. **练习2**: 在列表页添加下拉刷新和上拉加载
3. **练习3**: 实现一个带动画的页面切换效果
4. **练习4**: 创建一个自定义的 BaseService，管理应用主题

---

## 📖 相关文档

- [主项目 README](../README.md) - 完整的 API 文档
- [CLAUDE.md](../CLAUDE.md) - 架构说明
- [FAQ](../FAQ.md) - 常见问题

---

## 🤝 反馈

如有问题或建议，欢迎提交 Issue：
https://github.com/BlueSkyYk/flutter_components_base_getx/issues

---

**祝你学习愉快！如果这个示例对你有帮助，请给项目一个 Star ⭐️**
