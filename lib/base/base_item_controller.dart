import 'base_controller.dart';

abstract class BaseItemController extends BaseController {
  bool _itemShowing = false;

  bool get itemShowing => _itemShowing;

  void updateItemShowStatus(bool showing) {
    if (_itemShowing == showing) {
      return;
    }
    _itemShowing = showing;
    if (_itemShowing) {
      pageShow();
    } else {
      pageHide();
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
