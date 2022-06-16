import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navbar_router/navbar_router.dart';

import 'navbar_utils.dart';

void main() {
  List<IconData> icons = [Icons.home, Icons.shopping_basket, Icons.person];

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
                  for (int i = 0; i < icons.length; i++)
                    DestinationRouter(
                      navbarItem: NavbarItem(icons[i], 'Home',
                          backgroundColor: colors[i]),
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

  group('navbar_router sanitary tests: ', () {
    testWidgets('navbar_router should require atleast two routes',
        (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate());
      expect(find.text(''), findsOneWidget);
    });
  });
}
