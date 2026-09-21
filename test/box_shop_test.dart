import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrition_app/screens/box_shop_screen.dart';
import 'package:nutrition_app/services/box_store.dart';
import 'package:nutrition_app/theme.dart';

void main() {
  testWidgets('phone storefront filters Arabic boxes without overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final store = BoxStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(ChangeNotifierProvider.value(value: store, child: MaterialApp(theme: buildLightTheme(), home: const Scaffold(body: BoxShopScreen()))));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(find.byType(TextField), 'مجبوس');
    await tester.pumpAndSettle();
    expect(find.text('Chicken Machboos'), findsOneWidget);
    expect(find.text('Lamb Mansaf'), findsNothing);
    await tester.enterText(find.byType(TextField), 'no matching recipe');
    await tester.pump();
    expect(find.text('No boxes here yet. Try another search or save a favourite.'), findsOneWidget);
  });
  testWidgets('checkout validates area before saving and clearing basket', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = BoxStore(await SharedPreferences.getInstance());
    await store.setQuantity('machboos', 1);
    await tester.pumpWidget(ChangeNotifierProvider.value(value: store, child: MaterialApp(theme: buildLightTheme(), home: const CheckoutScreen())));
    await tester.tap(find.text('Save demo order'));
    await tester.pump();
    expect(find.text('Enter a delivery area'), findsOneWidget);
    expect(store.count, 1);
    await tester.enterText(find.byType(TextFormField), 'Manama');
    await tester.tap(find.text('Save demo order'));
    await tester.pumpAndSettle();
    expect(find.text('Demo order saved'), findsOneWidget);
    expect(store.orders.length, 1);
    expect(store.count, 0);
  });
}
