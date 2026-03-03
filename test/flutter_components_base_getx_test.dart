import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_components_base_getx/flutter_components_base_getx.dart';

void main() {
  group('flutter_components_base_getx', () {
    test('exports BaseController', () {
      expect(BaseController, isNotNull);
    });

    test('exports BasePage', () {
      expect(BasePage, isNotNull);
    });

    test('exports BaseService', () {
      expect(BaseService, isNotNull);
    });

    test('exports BaseItemController', () {
      expect(BaseItemController, isNotNull);
    });

    test('exports AppRouteObserver', () {
      expect(AppRouteObserver, isNotNull);
    });

    test('exports KeepAliveWrapper', () {
      expect(KeepAliveWrapper, isNotNull);
    });

    test('exports ListenerMixin', () {
      expect(ListenerMixin, isNotNull);
    });

    test('global appRouteObserver instance is available', () {
      expect(appRouteObserver, isNotNull);
      expect(appRouteObserver, isA<AppRouteObserver>());
    });
  });
}
