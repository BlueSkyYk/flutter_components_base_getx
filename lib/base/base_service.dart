import 'package:get/get.dart';

import '../components/listener_mixin.dart';

abstract class BaseService extends GetxService with ListenerMixin {}

class ListenableDataModel<T> {
  final Rx<T> _data;

  ListenableDataModel(Rx<T> data) : _data = data;

  T get data => _data.value;

  RxInterface<T> get listener => _data;
}
