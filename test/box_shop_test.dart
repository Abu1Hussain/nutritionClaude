import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrition_app/screens/box_shop_screen.dart';
import 'package:nutrition_app/services/app_state.dart';
import 'package:nutrition_app/services/box_store.dart';
import 'package:nutrition_app/theme.dart';

void main() {
  testWidgets('phone storefront filters Arabic boxes without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final store = BoxStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: store),
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const Scaffold(body: BoxShopScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), 'مجبوس');
    await tester.pumpAndSettle();
    expect(find.text('Chicken Machboos'), findsOneWidget);
    expect(find.text('Lamb Mansaf'), findsNothing);
    await tester.enterText(find.byType(TextField), 'no matching recipe');
    await tester.pump();
    expect(
      find.text('ما لقينا وجبات هنا. جرّب بحثًا آخر أو أضف وجبة للمفضلة.'),
      findsOneWidget,
    );
  });
  testWidgets('checkout validates area before saving and clearing basket', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final store = BoxStore(await SharedPreferences.getInstance());
    await store.setQuantity('machboos', 1);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: store),
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: MaterialApp(
          theme: buildLightTheme(),
          home: const CheckoutScreen(),
        ),
      ),
    );
    await tester.tap(find.text('حفظ الطلب التجريبي'));
    await tester.pump();
    expect(find.text('أدخل منطقة التوصيل'), findsOneWidget);
    expect(store.count, 1);
    await tester.enterText(find.byType(TextFormField), 'Manama');
    await tester.tap(find.text('حفظ الطلب التجريبي'));
    await tester.pumpAndSettle();
    expect(find.text('تم حفظ الطلب التجريبي'), findsOneWidget);
    expect(store.orders.length, 1);
    expect(store.count, 0);
  });
}
