import 'package:example/main.dart' as app;
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:navbar_router/navbar_router.dart';

extension FindText on String {
  Finder textX() => find.text(this);
}

extension FindKey on Key {
  Finder keyX() => find.byKey(this);
}

extension FindType on Type {
  Finder typeX() => find.byType(this);
}

extension FindWidget on Widget {
  Finder widgetX() => find.byWidget(this);
}

extension FindIcon on IconData {
  Finder iconX() => find.byIcon(this);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  List<NavbarItem> items = [
    NavbarItem(Icons.home, 'Home', backgroundColor: colors[0]),
    NavbarItem(Icons.shopping_bag, 'Products', backgroundColor: colors[1]),
    NavbarItem(Icons.person, 'Me', backgroundColor: colors[2]),
    NavbarItem(Icons.settings, 'Settings', backgroundColor: colors[0]),
  ];

  const Map<int, Map<String, Widget>> _routes = {
    0: {
      '/': HomeFeeds(),
      FeedDetail.route: FeedDetail(),
    },
    1: {
      '/': ProductList(),
      ProductDetail.route: ProductDetail(),
      ProductComments.route: ProductComments(),
    },
    2: {
      '/': UserProfile(),
      ProfileEdit.route: ProfileEdit(),
    },
    3: {
      '/': Settings(),
    },
  };
  group('Integration test:', () {
    testWidgets('Test widgets load', (WidgetTester tester) async {
      app.main();
      await Future.delayed(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect((app.MyApp).typeX(), findsOneWidget);
      expect((app.HomePage).typeX(), findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));
      expect((NavbarRouter).typeX(), findsOneWidget);
      for (int i = 0; i < items.length; i++) {
        expect((items[i].iconData).iconX(), findsOneWidget);
        expect((items[0].text).textX(), findsOneWidget);
      }
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(items[1].iconData.iconX());
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      expect((app.ProductList).typeX(), findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(items[2].iconData.iconX());
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      expect((app.UserProfile).typeX(), findsOneWidget);
      await Future.delayed(const Duration(seconds: 1));
      await tester.tap(items[3].iconData.iconX());
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 1));
      expect((app.Settings).typeX(), findsOneWidget);
    });
  });
}
