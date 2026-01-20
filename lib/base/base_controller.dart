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

  TickerProvider? _tickerProvider;

  TickerProvider? get tickerProvider => _tickerProvider;

  final ValueNotifier<bool> canGesturePop = ValueNotifier<bool>(true);

  @override
  void onReady() {
    super.onReady();
    _firstShowHandled = true;
    pageShow();
  }

  void updateCanPop(bool canPop) {
    canGesturePop.value = canPop;
  }

  void setTickerProvider(TickerProvider provider) {
    _tickerProvider = provider;
  }

  void removeTickerProvider() {
    _tickerProvider = null;
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

  void popInvokedWithResult(bool didPop, dynamic result) {
    onPopInvokedWithResult(didPop, result);
  }

  @protected
  void onPageInit() {}

  @protected
  void onPageShow() {}

  @protected
  void onPageHide() {}

  @protected
  void onPageDispose() {}

  @protected
  void onPopInvokedWithResult(bool didPop, dynamic result) {}
}
