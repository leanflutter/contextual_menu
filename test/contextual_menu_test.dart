import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:contextual_menu/contextual_menu.dart';

void main() {
  const MethodChannel channel = MethodChannel('contextual_menu');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await ContextualMenu.platformVersion, '42');
  // });
}
