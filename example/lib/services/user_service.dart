import 'package:flutter_components_base_getx/base/base_service.dart';
import 'package:get/get.dart';

/// 用户服务示例
/// 展示如何使用 BaseService 和 ListenableDataModel
class UserService extends BaseService {
  // 私有响应式数据
  final _userName = Rx<String>('访客');
  final _userAge = Rx<int>(0);
  final _tags = RxList<String>(['新用户']);

  // 通过 ListenableDataModel 暴露给外部
  // 这样可以隐藏 Rx 的可变性，只暴露监听和读取接口
  ListenableDataModel<String> get userNameModel =>
      ListenableDataModel(_userName);

  ListenableDataModel<int> get userAgeModel => ListenableDataModel(_userAge);

  ListenableListDataModel<String> get tagsModel =>
      ListenableListDataModel(_tags);

  // 获取当前数据（非响应式）
  String get userName => _userName.value;
  int get userAge => _userAge.value;
  List<String> get tags => _tags;

  @override
  void onInit() {
    super.onInit();
    print('🔧 UserService 初始化');

    // 使用 ListenerMixin 的 listen 方法监听变化
    listen(_userName, (value) {
      print('👤 用户名变化: $value');
    });

    listen(_userAge, (value) {
      print('🎂 年龄变化: $value');
    });
  }

  /// 更新用户信息
  void updateUserName(String name) {
    _userName.value = name;
  }

  void updateUserAge(int age) {
    _userAge.value = age;
  }

  void addTag(String tag) {
    _tags.add(tag);
  }

  void removeTag(String tag) {
    _tags.remove(tag);
  }

  /// 模拟从服务器加载用户数据
  Future<void> loadUserData() async {
    print('🌐 开始加载用户数据...');
    await Future.delayed(const Duration(seconds: 1));
    _userName.value = '张三';
    _userAge.value = 25;
    _tags.assignAll(['VIP用户', '活跃用户', '新手指引已完成']);
    print('✅ 用户数据加载完成');
  }

  @override
  void onClose() {
    print('🔧 UserService 销毁');
    super.onClose();
  }
}
