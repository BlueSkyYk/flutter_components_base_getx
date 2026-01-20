import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class BaseController extends GetxController {
  bool _isInitialized = false;
  bool _isVisible = false;
  bool _isDisposed = false;

  bool get isInitialized => _isInitialized;

  bool get isVisible => _isVisible;

  bool get isDisposed => _isDisposed;

  bool _firstShowHandled = false;

  @override
  void onReady() {
    super.onReady();
    _firstShowHandled = true;
    pageShow();
  }

  void pageInit() {
    _isInitialized = true;
    onPageInit();
  }

  void pageShow() {
    if (_isDisposed) return;
    if (!_firstShowHandled) return;
    if (_isVisible) return;
    _isVisible = true;
    onPageShow();
  }

  void pageHide() {
    if (_isDisposed) return;
    if (!_isVisible) return;
    _isVisible = false;
    onPageHide();
  }

  void pageDispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    onPageDispose();
  }

  @protected
  void onPageInit() {}

  @protected
  void onPageShow() {}

  @protected
  void onPageHide() {}

  @protected
  void onPageDispose() {}
}
