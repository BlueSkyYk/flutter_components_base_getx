import 'package:get/get.dart';

import '../components/listener_mixin.dart';

abstract class BaseService extends GetxService with ListenerMixin {}

class ListenableDataModel<T> {
  final Rx<T> _data;

  ListenableDataModel(Rx<T> data) : _data = data;

  T get data => _data.value;

  RxInterface<T> get listener => _data;
}

class ListenableListDataModel<T> {
  final RxList<T> _data;

  ListenableListDataModel(RxList<T> data) : _data = data;

  List<T> get data => _data;

  RxInterface<List<T>> get listener => _data;
}

class ListenableMapDataModel<K, V> {
  final RxMap<K, V> _data;

  ListenableMapDataModel(RxMap<K, V> data) : _data = data;

  Map<K, V> get data => _data;

  RxInterface<Map<K, V>> get listener => _data;
}

class ListenableSetDataModel<T> {
  final RxSet<T> _data;

  ListenableSetDataModel(RxSet<T> data) : _data = data;

  Set<T> get data => _data;

  RxInterface<Set<T>> get listener => _data;
}
