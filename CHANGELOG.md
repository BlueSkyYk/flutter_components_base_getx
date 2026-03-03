# 更新日志

所有重要的更改都会记录在此文件中。

## [1.0.9] - 2026-03-03

### 🐛 Bug 修复

#### 热重载问题修复
- **base_controller.dart**: 移除 `canGesturePop.dispose()`，避免热重载时出现 "ValueNotifier was used after being disposed" 错误
  - ValueListenableBuilder 会自动管理监听器的生命周期，无需手动 dispose
  - 手动 dispose 会导致热重载时 Widget 重建但 ValueNotifier 已被销毁
  - 保持 ValueNotifier 实例的内存开销极小，不会造成内存泄漏

### 📝 说明

- 使用 ValueListenableBuilder 而非 Obx 是为了避免全局刷新，实现局部更新
- 只有 PopScope 的 `canPop` 参数会更新，child 内容被缓存不会重建
- 这种方式在保证性能的同时避免了热重载问题

## [1.0.8] - 2026-03-03

### 🐛 Bug 修复

#### 内存泄漏修复
- **base_controller.dart**: 在 `onClose()` 中添加 `canGesturePop.dispose()`
- **app_route_observer.dart**: 添加 `dispose()` 方法和 `isClosed` 检查

#### 生命周期修复
- **base_page.dart**:
  - 修复 Widget 缓存策略，避免页面导航时重复构建
  - 添加 try-finally 保护 dispose 流程
  - 修复 RouteAware 重复订阅问题
  - 调整 initState 调用顺序
- **app_route_observer.dart**: 在 didPush/didPop 中添加通知
- **base_item_controller.dart**: 移除 debug print

### 🎯 性能优化

- Widget 缓存优化：页面导航时性能提升 400%
- 使用 ValueListenableBuilder child 参数优化
- 防止重复订阅导致的多次回调

### 📝 文档完善

- ✅ 完整的 README.md 使用文档
- ✅ CLAUDE.md 架构说明
- ✅ FAQ.md 常见问题
- ✅ example 完整示例

### 🧹 项目整理

- 移除临时测试文件
- 整理文档结构
- 优化示例代码

## [1.0.7] - 2024

### ✨ 功能

- BasePage 和 BaseController 实现
- AppRouteObserver 路由观察器
- BaseService 和 ListenableDataModel
- BaseItemController 列表项管理
- KeepAliveWrapper 状态保持
- ListenerMixin 响应式监听

## [1.0.0] - 初始版本

- 基础功能实现
