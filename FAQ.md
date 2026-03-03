# 常见问题 FAQ

## 关于 AppRouteObserver 的 dispose() 方法

### 问题：为什么 AppRouteObserver 有 dispose() 方法但从不调用？

**答案**：这是设计上的考虑。`appRouteObserver` 是全局单例，在应用的整个生命周期中存在，通常不需要手动调用 `dispose()`。

### 何时需要调用 dispose()？

只在以下**特殊场景**需要调用：

#### 1. 单元测试

```dart
void main() {
  late AppRouteObserver observer;

  setUp(() {
    observer = AppRouteObserver();
  });

  tearDown(() {
    observer.dispose(); // 清理测试资源
  });

  test('测试路由功能', () {
    // ...
  });
}
```

#### 2. 集成测试

```dart
testWidgets('测试应用流程', (tester) async {
  final testObserver = AppRouteObserver();

  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: [testObserver],
      home: HomePage(),
    ),
  );

  // 执行测试...

  testObserver.dispose(); // 测试结束后清理
});
```

#### 3. 动态模块场景

如果您的应用使用动态模块加载/卸载：

```dart
class MyModule {
  late AppRouteObserver _moduleObserver;

  void init() {
    _moduleObserver = AppRouteObserver();
    // 使用 _moduleObserver...
  }

  void unload() {
    _moduleObserver.dispose(); // 模块卸载时清理
  }
}
```

### 正常应用场景（不需要 dispose）

```dart
// lib/component.dart
final AppRouteObserver appRouteObserver = AppRouteObserver();

// main.dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [appRouteObserver], // 全局单例
      home: HomePage(),
    );
  }
}

// 不需要在任何地方调用 appRouteObserver.dispose()
// 应用关闭时，系统会自动清理
```

### 为什么保留 dispose() 方法？

1. **测试友好**：单元测试需要独立的实例和清理
2. **灵活性**：支持特殊场景（动态模块、多实例等）
3. **资源管理**：遵循 Flutter 的资源管理最佳实践
4. **无副作用**：保留此方法不会影响正常使用

### 总结

| 场景 | 是否需要 dispose | 说明 |
|------|-----------------|------|
| 正常应用 | ❌ 否 | 全局单例，应用关闭时自动清理 |
| 单元测试 | ✅ 是 | 每个测试独立实例，tearDown 中调用 |
| 集成测试 | ✅ 是 | 测试结束后清理资源 |
| 动态模块 | ✅ 是 | 模块卸载时清理 |
| 多实例场景 | ✅ 是 | 不再使用的实例需要清理 |

---

## 其他常见问题

### Q: 页面生命周期为什么没有触发？

**A**: 确保在 MaterialApp 中添加了路由观察器：

```dart
MaterialApp(
  navigatorObservers: [appRouteObserver], // 必须添加！
  home: HomePage(),
)
```

### Q: 如何控制手势返回？

**A**: 使用 `updateCanPop()` 方法：

```dart
class MyController extends BaseController {
  void enableBackGesture(bool enable) {
    updateCanPop(enable);
  }
}
```

### Q: BaseItemController 和 BaseController 有什么区别？

**A**:
- `BaseController`: 用于普通页面
- `BaseItemController`: 用于列表项、网格项等需要独立生命周期管理的组件

### Q: KeepAliveWrapper 什么时候用？

**A**: 用于保持 Widget 状态不被销毁，常见场景：
- TabBarView 的 Tab 页面
- PageView 的页面
- 需要缓存状态的列表项

### Q: 如何在 Service 中使用响应式数据？

**A**: 使用 `ListenableDataModel` 封装：

```dart
class UserService extends BaseService {
  final _userName = Rx<String>('');

  ListenableDataModel<String> get userNameModel =>
      ListenableDataModel(_userName);

  void updateUserName(String name) {
    _userName.value = name;
  }
}
```

---

更多问题？欢迎在 [GitHub Issues](https://github.com/BlueSkyYk/flutter_components_base_getx/issues) 提问！
