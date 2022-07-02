import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navbar_router/navbar_router.dart';

import 'navbar_utils.dart';

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

void main() {
  List<NavbarItem> items = [
    NavbarItem(Icons.home, 'Home', backgroundColor: colors[0]),
    NavbarItem(Icons.shopping_bag, 'Products', backgroundColor: colors[1]),
    NavbarItem(Icons.person, 'Me', backgroundColor: colors[2]),
  ];
  final Map<int, Map<String, Widget>> routes = {
    0: {
      '/': const HomeFeeds(),
      FeedDetail.route: const FeedDetail(),
    },
    1: {
      '/': const ProductList(),
      ProductDetail.route: const ProductDetail(),
    },
    2: {
      '/': const UserProfile(),
      ProfileEdit.route: const ProfileEdit(),
    },
  };

  Widget _boilerplate() {
    return MaterialApp(
      home: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
              data: const MediaQueryData(size: Size(800.0, 600.0)),
              child: NavbarRouter(
                errorBuilder: (context) {
                  return const Center(child: Text('Error 404'));
                },
                onBackButtonPressed: (isExiting) {
                  return isExiting;
                },
                destinationAnimationCurve: Curves.fastOutSlowIn,
                destinationAnimationDuration: 600,
                decoration: NavbarDecoration(
                    navbarType: BottomNavigationBarType.shifting),
                destinations: [
                  for (int i = 0; i < items.length; i++)
                    DestinationRouter(
                      navbarItem: items[i],
                      destinations: [
                        for (int j = 0; j < routes[i]!.keys.length; j++)
                          Destination(
                            route: routes[i]!.keys.elementAt(j),
                            widget: routes[i]!.values.elementAt(j),
                          ),
                      ],
                      initialRoute: routes[i]!.keys.first,
                    ),
                ],
              ))),
    );
  }

  group('navbar_router should build destination and navbar items', () {
    testWidgets('navbar_router should build destinations',
        (WidgetTester tester) async {
      final listView = (ListView).typeX();
      await tester.pumpWidget(_boilerplate());
      expect('Feeds'.textX(), findsOneWidget);
      expect(listView, findsWidgets);
      expect('Feed 1 card'.textX(), findsOneWidget);
      final card5Text = 'Feed 5 card'.textX();
      await tester.dragUntilVisible(
          card5Text, listView.first, const Offset(0, -50.0));
      await tester.tap(card5Text);
      await tester.pumpAndSettle();
      expect((FeedDetail).typeX(), findsOneWidget);
    });
  });
  group('navbar_router should build navbar items', () {
    testWidgets('', (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate());
      expect(find.text(items[0].text), findsOneWidget);
      // Products text also fuound on the appbar
      expect(find.text(items[1].text), findsWidgets);
      expect(find.text(items[2].text), findsOneWidget);
    });
  });
}
