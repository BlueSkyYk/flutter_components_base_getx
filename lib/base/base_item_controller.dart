import 'base_controller.dart';

abstract class BaseItemController extends BaseController {
  bool _itemShowing = false;

  bool get itemShowing => _itemShowing;

  void updateItemShowStatus(bool showing) {
    print(
      "${runtimeType} - updateItemShowStatus($showing) - itemShowing: $_itemShowing - visible: $isVisible",
    );
    if (_itemShowing == showing) {
      return;
    }
    _itemShowing = showing;
    if (_itemShowing) {
      super.pageShow();
    } else {
      super.pageHide();
    }
  }

  @override
  void pageShow() {
    if (!_itemShowing) return;
    super.pageShow();
  }

  @override
  void pageHide() {
    if (!_itemShowing) return;
    super.pageHide();
  }
}
