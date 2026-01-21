import 'package:get/get.dart';

mixin ListenerMixin on DisposableInterface {
  final List<Worker> _workers = [];

  List<Worker> get workers => _workers;

  Worker listen<T>(
    RxInterface<T> listener,
    WorkerCallback<T> callback, {
    dynamic condition = true,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final worker = ever(
      listener,
      callback,
      condition: condition,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    _workers.add(worker);
    return worker;
  }

  Worker listenAll<T>(
    List<RxInterface> listeners,
    WorkerCallback callback, {
    dynamic condition = true,
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final worker = everAll(
      listeners,
      callback,
      condition: condition,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    _workers.add(worker);
    return worker;
  }
}
