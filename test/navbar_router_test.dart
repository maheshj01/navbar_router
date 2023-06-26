import 'dart:io';
import 'dart:math';

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

extension FindIcon on IconData {
  Finder iconX() => find.byIcon(this);
}

void main() {
  const List<NavbarItem> items = [
    NavbarItem(Icons.home, 'Home', backgroundColor: mediumPurple),
    NavbarItem(Icons.shopping_bag, 'Products', backgroundColor: Colors.orange),
    NavbarItem(Icons.person, 'Me', backgroundColor: Colors.teal),
  ];
  const Map<int, Map<String, Widget>> routes = {
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
  };

  Widget boilerplate(
      {bool isDesktop = false,
      BackButtonBehavior behavior = BackButtonBehavior.exit,
      Map<int, Map<String, Widget>> navBarRoutes = routes,
      NavbarType type = NavbarType.standard,
      NavbarDecoration? decoration,
      int index = 0,
      List<NavbarItem> navBarItems = items}) {
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
                initialIndex: index,
                type: type,
                backButtonBehavior: behavior,
                isDesktop: isDesktop,
                destinationAnimationCurve: Curves.fastOutSlowIn,
                destinationAnimationDuration: 600,
                decoration: decoration ??
                    NavbarDecoration(
                        navbarType: BottomNavigationBarType.shifting),
                destinations: [
                  for (int i = 0; i < navBarItems.length; i++)
                    DestinationRouter(
                      navbarItem: navBarItems[i],
                      destinations: [
                        for (int j = 0; j < navBarRoutes[i]!.keys.length; j++)
                          Destination(
                            route: navBarRoutes[i]!.keys.elementAt(j),
                            widget: navBarRoutes[i]!.values.elementAt(j),
                          ),
                      ],
                      initialRoute: navBarRoutes[i]!.keys.first,
                    ),
                ],
              ))),
    );
  }

  group('Test NavbarType: NavbarType.standard ', () {
    group('NavbarType.standard: should build destination and navbar items', () {
      testWidgets('NavbarType.standard: should build destinations',
          (WidgetTester tester) async {
        final bottomNavigation = (BottomNavigationBar).typeX();
        final navigationRail = (NavigationRail).typeX();

        await tester.pumpWidget(boilerplate());
        await tester.pumpAndSettle();
        expect(navigationRail, findsNothing);
        expect(bottomNavigation, findsOneWidget);

        for (int i = 0; i < items.length; i++) {
          final icon = find.byIcon(items[i].iconData);
          final destination = (routes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
      });

      testWidgets('NavbarType.standard: should build navbarItem labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate());
        expect(find.text(items[0].text), findsOneWidget);
        expect(find.text(items[1].text), findsWidgets);
        expect(find.text(items[2].text), findsOneWidget);
      });

      testWidgets(
          "NavbarType.standard: should allow updating navbar routes dynamically ",
          (WidgetTester tester) async {
        List<NavbarItem>? menuitems = [
          const NavbarItem(Icons.home, 'Home', backgroundColor: mediumPurple),
          const NavbarItem(Icons.shopping_bag, 'Products',
              backgroundColor: Colors.orange),
          const NavbarItem(Icons.person, 'Me', backgroundColor: Colors.teal),
        ];
        Map<int, Map<String, Widget>>? navBarRoutes = {
          0: {
            '/': const HomeFeeds(),
            FeedDetail.route: const FeedDetail(),
          },
          1: {
            '/': const ProductList(),
            ProductDetail.route: const ProductDetail(),
            ProductComments.route: const ProductComments(),
          },
          2: {
            '/': const UserProfile(),
            ProfileEdit.route: const ProfileEdit(),
          },
        };
        await tester.pumpWidget(boilerplate(
          navBarItems: menuitems,
          navBarRoutes: navBarRoutes,
        ));
        await tester.pumpAndSettle();
        final bottomNavigation = (BottomNavigationBar).typeX();
        expect(bottomNavigation, findsOneWidget);

        for (int i = 0; i < menuitems.length; i++) {
          final icon = find.byIcon(menuitems[i].iconData);
          final destination = (navBarRoutes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
        int randomIndex = Random().nextInt(menuitems.length);
        menuitems.add(items[randomIndex]);
        navBarRoutes[navBarRoutes.length] = routes[randomIndex]!;
        await tester.pumpAndSettle();
        for (int i = 0; i < menuitems.length; i++) {
          final icon = find.byIcon(menuitems[i].iconData);
          final destination = (navBarRoutes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
      });
    });
    testWidgets('NavbarType.standard: default index must be zero',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      expect(NavbarNotifier.currentIndex, 0);
      final destination = (routes[0]!['/']).runtimeType.typeX();
      expect(destination, findsOneWidget);
      final icon = find.byIcon(items[0].iconData);
      expect(icon, findsOneWidget);
    });
    testWidgets('NavbarType.standard: Set initial index to non-zero',
        (WidgetTester tester) async {
      int initialIndex = 2;
      await tester.pumpWidget(
          boilerplate(type: NavbarType.standard, index: initialIndex));
      expect(NavbarNotifier.currentIndex, initialIndex);
      final destination = (routes[initialIndex]!['/']).runtimeType.typeX();
      expect(destination, findsOneWidget);
      final icon = find.byIcon(items[initialIndex].iconData);
      expect(icon, findsOneWidget);
    });

    testWidgets(
        'NavbarType.standard: should switch to Navigation Rail in Desktop mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      await tester.pumpWidget(boilerplate(isDesktop: true));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    group('NavbarType.standard: should respect BackButtonBehavior', () {
      Future<void> changeNavbarDestination(
          WidgetTester tester, Widget destination, IconData iconData) async {
        final icon = find.byIcon(iconData);
        final destinationType = destination.runtimeType.typeX();
        expect(icon, findsOneWidget);
        await tester.tap(icon);
        await tester.pumpAndSettle();
        expect(destinationType, findsOneWidget);
      }

      Future<void> navigateToNestedTarget(
          WidgetTester tester, Finder tapTarget, Widget destination) async {
        expect(tapTarget, findsOneWidget);
        await tester.tap(tapTarget);
        await tester.pumpAndSettle();
        final destinationFinder = (destination).runtimeType.typeX();
        expect(destinationFinder, findsOneWidget);
      }

      Future<void> triggerBackButton(WidgetTester tester) async {
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();
      }

      testWidgets(
          'Navbar should exit app when at the root of the Navigator stack(default)',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate());
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        /// verify feeds is the current destination
        await changeNavbarDestination(
            tester, routes[0]!['/']!, items[0].iconData);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, items[1].iconData);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 0".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, items[2].iconData);

        /// Navigate to ProfileEdit
        await navigateToNestedTarget(
            tester, (Icons.edit).iconX(), routes[2]![ProfileEdit.route]!);

        await triggerBackButton(tester);
        expect(
            routes[2]![UserProfile.route].runtimeType.typeX(), findsOneWidget);

        /// This will exit the app
        await triggerBackButton(tester);
        expect(exitCode, 0);
      });
      testWidgets('Navbar should remember navigation history',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            boilerplate(behavior: BackButtonBehavior.rememberHistory));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(BottomNavigationBar), findsOneWidget);

        /// verify feeds is the current destination
        await changeNavbarDestination(
            tester, routes[0]!['/']!, items[0].iconData);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, items[1].iconData);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 0".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, items[2].iconData);

        /// Navigate to ProfileEdit
        await navigateToNestedTarget(
            tester, (Icons.edit).iconX(), routes[2]![ProfileEdit.route]!);

        expect(NavbarNotifier.stackHistory, equals([0, 1, 2]));

        await triggerBackButton(tester);
        await triggerBackButton(tester);
        expect(NavbarNotifier.stackHistory, equals([0, 1]));

        await triggerBackButton(tester);
        await triggerBackButton(tester);
        await triggerBackButton(tester);
        expect(NavbarNotifier.stackHistory, equals([0]));
      });
    });

    group('NavbarType.standard: Should Pop routes Programmatically', () {
      testWidgets('Navbar should pop route programmatically',
          (WidgetTester tester) async {
        int index = 1;
        await tester.pumpWidget(boilerplate());
        await tester.pumpAndSettle();
        final productIcon = find.byIcon(items[index].iconData);
        final productDestination = (routes[index]!['/']).runtimeType.typeX();
        expect(productIcon, findsOneWidget);
        await tester.tap(productIcon);
        await tester.pumpAndSettle();
        expect(productDestination, findsOneWidget);

        /// Navigate to ProductDetail

        await tester.tap("Product 0".textX());
        await tester.pumpAndSettle();
        final productDetail =
            (routes[1]![ProductDetail.route]).runtimeType.typeX();
        expect(productDetail, findsOneWidget);
        NavbarNotifier.popRoute(index);
        await tester.pumpAndSettle();
        expect(productDetail, findsNothing);
        expect(productDestination, findsOneWidget);
      });

      testWidgets('Navbar should pop to base route programmatically',
          (WidgetTester tester) async {
        int index = 1;
        await tester.pumpWidget(boilerplate());
        await tester.pumpAndSettle();
        final productIcon = find.byIcon(items[index].iconData);
        final productDestination = (routes[index]!['/']).runtimeType.typeX();
        expect(productIcon, findsOneWidget);
        await tester.tap(productIcon);
        await tester.pumpAndSettle();
        expect(productDestination, findsOneWidget);

        /// Navigate to ProductDetail

        await tester.tap("Product 0".textX());
        await tester.pumpAndSettle();
        final productDetail =
            (routes[1]![ProductDetail.route]).runtimeType.typeX();
        expect(productDetail, findsOneWidget);

        /// Navigate to Product comments

        await tester.tap("show comments".textX());
        await tester.pumpAndSettle();
        final productComments =
            (routes[1]![ProductComments.route]).runtimeType.typeX();
        expect(productComments, findsOneWidget);
        NavbarNotifier.popAllRoutes(index);
        await tester.pumpAndSettle();

        expect(productComments, findsNothing);
        expect(productDetail, findsNothing);
        expect(productDestination, findsOneWidget);
      });
    });
  });

  /// Test navbar type notched
  ///

  group('Test NavbarType: NavbarType.notched ', () {
    group('NavbarType.notched: should build destination and navbar items', () {
      testWidgets('navbar_router should build destinations',
          (WidgetTester tester) async {
        final navbar = (NotchedNavBar).typeX();
        final navigationRail = (NavigationRail).typeX();

        await tester.pumpWidget(boilerplate(
          type: NavbarType.notched,
        ));
        await tester.pumpAndSettle();
        expect(navigationRail, findsNothing);
        expect(navbar, findsOneWidget);

        for (int i = 0; i < items.length; i++) {
          final icon = find.byIcon(items[i].iconData);
          final destination = (routes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
      });

      testWidgets('NavbarType.notched: should build navbarItem labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          type: NavbarType.notched,
        ));
        expect(
            find.text(items[0].text), findsNothing); // 0 is selected by default
        expect(find.text(items[1].text), findsWidgets);
        expect(find.text(items[2].text), findsOneWidget);
      });

      testWidgets(
          "NavbarType.notched: should allow updating navbar routes dynamically ",
          (WidgetTester tester) async {
        List<NavbarItem>? menuitems = [
          const NavbarItem(Icons.home, 'Home', backgroundColor: mediumPurple),
          const NavbarItem(Icons.shopping_bag, 'Products',
              backgroundColor: Colors.orange),
          const NavbarItem(Icons.person, 'Me', backgroundColor: Colors.teal),
        ];
        Map<int, Map<String, Widget>>? navBarRoutes = {
          0: {
            '/': const HomeFeeds(),
            FeedDetail.route: const FeedDetail(),
          },
          1: {
            '/': const ProductList(),
            ProductDetail.route: const ProductDetail(),
            ProductComments.route: const ProductComments(),
          },
          2: {
            '/': const UserProfile(),
            ProfileEdit.route: const ProfileEdit(),
          },
        };
        await tester.pumpWidget(boilerplate(
          navBarItems: menuitems,
          navBarRoutes: navBarRoutes,
          type: NavbarType.notched,
        ));
        await tester.pumpAndSettle();
        final navbar = (NotchedNavBar).typeX();
        expect(navbar, findsOneWidget);

        for (int i = 0; i < menuitems.length; i++) {
          final icon = find.byIcon(menuitems[i].iconData);
          final destination = (navBarRoutes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
        int randomIndex = Random().nextInt(menuitems.length);
        menuitems.add(items[randomIndex]);
        navBarRoutes[navBarRoutes.length] = routes[randomIndex]!;
        await tester.pumpAndSettle();
        for (int i = 0; i < menuitems.length; i++) {
          final icon = find.byIcon(menuitems[i].iconData);
          final destination = (navBarRoutes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
      });

      testWidgets('NavbarType.notched: default index must be zero',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          type: NavbarType.notched,
        ));
        expect(NavbarNotifier.currentIndex, 0);
        final destination = (routes[0]!['/']).runtimeType.typeX();
        expect(destination, findsOneWidget);
        final icon = find.byIcon(items[0].iconData);
        expect(icon, findsOneWidget);
      });

      testWidgets('NavbarType.notched: Set initial index to non-zero',
          (WidgetTester tester) async {
        int initialIndex = 2;
        await tester.pumpWidget(
            boilerplate(type: NavbarType.notched, index: initialIndex));
        expect(NavbarNotifier.currentIndex, initialIndex);
        final destination = (routes[initialIndex]!['/']).runtimeType.typeX();
        expect(destination, findsOneWidget);
        final icon = find.byIcon(items[initialIndex].iconData);
        expect(icon, findsOneWidget);
      });

      testWidgets(
          'NavbarType.notched: should switch to Navigation Rail in Desktop mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          type: NavbarType.notched,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(NotchedNavBar), findsOneWidget);
        await tester.pumpWidget(boilerplate(isDesktop: true));
        await tester.pumpAndSettle();
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(NotchedNavBar), findsNothing);
      });
    });

    group('NavbarType.notched: should respect BackButtonBehavior', () {
      Future<void> changeNavbarDestination(
          WidgetTester tester, Widget destination, IconData iconData) async {
        final icon = find.byIcon(iconData);
        final destinationType = destination.runtimeType.typeX();
        expect(icon, findsOneWidget);
        await tester.tap(icon);
        await tester.pumpAndSettle();
        expect(destinationType, findsOneWidget);
      }

      Future<void> navigateToNestedTarget(
          WidgetTester tester, Finder tapTarget, Widget destination) async {
        expect(tapTarget, findsOneWidget);
        await tester.tap(tapTarget);
        await tester.pumpAndSettle();
        final destinationFinder = (destination).runtimeType.typeX();
        expect(destinationFinder, findsOneWidget);
      }

      Future<void> triggerBackButton(WidgetTester tester) async {
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();
      }

      testWidgets(
          'NavbarType.notched: should exit app when at the root of the Navigator stack(default)',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          type: NavbarType.notched,
        ));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(NotchedNavBar), findsOneWidget);

        /// verify feeds is the current destination
        await changeNavbarDestination(
            tester, routes[0]!['/']!, items[0].iconData);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, items[1].iconData);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 0".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, items[2].iconData);

        /// Navigate to ProfileEdit
        await navigateToNestedTarget(
            tester, (Icons.edit).iconX(), routes[2]![ProfileEdit.route]!);

        await triggerBackButton(tester);
        expect(
            routes[2]![UserProfile.route].runtimeType.typeX(), findsOneWidget);

        /// This will exit the app
        await triggerBackButton(tester);
        expect(exitCode, 0);
      });
      testWidgets('NavbarType.notched: should remember navigation history',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
            type: NavbarType.notched,
            behavior: BackButtonBehavior.rememberHistory));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(NotchedNavBar), findsOneWidget);

        /// verify feeds is the current destination
        await changeNavbarDestination(
            tester, routes[0]!['/']!, items[0].iconData);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, items[1].iconData);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 0".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, items[2].iconData);

        /// Navigate to ProfileEdit
        await navigateToNestedTarget(
            tester, (Icons.edit).iconX(), routes[2]![ProfileEdit.route]!);

        expect(NavbarNotifier.stackHistory, equals([0, 1, 2]));

        await triggerBackButton(tester);
        await triggerBackButton(tester);
        expect(NavbarNotifier.stackHistory, equals([0, 1]));

        await triggerBackButton(tester);
        await triggerBackButton(tester);
        await triggerBackButton(tester);
        expect(NavbarNotifier.stackHistory, equals([0]));
      });
    });

    group('NavbarType.notched: Should Pop routes Programmatically', () {
      testWidgets('Navbar should pop route programmatically',
          (WidgetTester tester) async {
        int index = 1;
        await tester.pumpWidget(boilerplate(
          type: NavbarType.notched,
        ));
        await tester.pumpAndSettle();
        final productIcon = find.byIcon(items[index].iconData);
        final productDestination = (routes[index]!['/']).runtimeType.typeX();
        expect(productIcon, findsOneWidget);
        await tester.tap(productIcon);
        await tester.pumpAndSettle();
        expect(productDestination, findsOneWidget);

        /// Navigate to ProductDetail

        await tester.tap("Product 0".textX());
        await tester.pumpAndSettle();
        final productDetail =
            (routes[1]![ProductDetail.route]).runtimeType.typeX();
        expect(productDetail, findsOneWidget);
        NavbarNotifier.popRoute(index);
        await tester.pumpAndSettle();
        expect(productDetail, findsNothing);
        expect(productDestination, findsOneWidget);
      });

      testWidgets('Navbar should pop to base route programmatically',
          (WidgetTester tester) async {
        int index = 1;
        await tester.pumpWidget(boilerplate(
          type: NavbarType.notched,
        ));
        await tester.pumpAndSettle();
        final productIcon = find.byIcon(items[index].iconData);
        final productDestination = (routes[index]!['/']).runtimeType.typeX();
        expect(productIcon, findsOneWidget);
        await tester.tap(productIcon);
        await tester.pumpAndSettle();
        expect(productDestination, findsOneWidget);

        /// Navigate to ProductDetail

        await tester.tap("Product 0".textX());
        await tester.pumpAndSettle();
        final productDetail =
            (routes[1]![ProductDetail.route]).runtimeType.typeX();
        expect(productDetail, findsOneWidget);

        /// Navigate to Product comments

        await tester.tap("show comments".textX());
        await tester.pumpAndSettle();
        final productComments =
            (routes[1]![ProductComments.route]).runtimeType.typeX();
        expect(productComments, findsOneWidget);
        NavbarNotifier.popAllRoutes(index);
        await tester.pumpAndSettle();

        expect(productComments, findsNothing);
        expect(productDetail, findsNothing);
        expect(productDestination, findsOneWidget);
      });
    });
  });

  group('Test NavbarType: NavbarType.material3 ', () {
    group(
        'NavbarType.material3: should build destination and navbar items (Desktop)',
        () {
      testWidgets('navbar_router should build destinations',
          (WidgetTester tester) async {
        final navbar = (M3NavBar).typeX();
        final navigationRail = (NavigationRail).typeX();

        await tester.pumpWidget(boilerplate(
          type: NavbarType.material3,
        ));
        await tester.pumpAndSettle();
        expect(navigationRail, findsNothing);
        expect(navbar, findsOneWidget);

        for (int i = 0; i < items.length; i++) {
          final icon = find.byIcon(items[i].iconData);
          final destination = (routes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
      });

      testWidgets('NavbarType.material3: should build navbarItem labels',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
            type: NavbarType.material3,
            index: 0,
            decoration: M3NavbarDecoration(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            )));
        await tester.pumpAndSettle();
        expect(find.text(items[0].text), findsOneWidget);
        expect(find.text(items[1].text), findsWidgets);
        expect(find.text(items[2].text), findsOneWidget);
      });

      testWidgets(
          "NavbarType.material3: should allow updating navbar routes dynamically ",
          (WidgetTester tester) async {
        List<NavbarItem>? menuitems = [
          const NavbarItem(Icons.home, 'Home', backgroundColor: mediumPurple),
          const NavbarItem(Icons.shopping_bag, 'Products',
              backgroundColor: Colors.orange),
          const NavbarItem(Icons.person, 'Me', backgroundColor: Colors.teal),
        ];
        Map<int, Map<String, Widget>>? navBarRoutes = {
          0: {
            '/': const HomeFeeds(),
            FeedDetail.route: const FeedDetail(),
          },
          1: {
            '/': const ProductList(),
            ProductDetail.route: const ProductDetail(),
            ProductComments.route: const ProductComments(),
          },
          2: {
            '/': const UserProfile(),
            ProfileEdit.route: const ProfileEdit(),
          },
        };
        await tester.pumpWidget(boilerplate(
          navBarItems: menuitems,
          navBarRoutes: navBarRoutes,
          type: NavbarType.material3,
        ));
        await tester.pumpAndSettle();
        final navbar = (M3NavBar).typeX();
        expect(navbar, findsOneWidget);

        for (int i = 0; i < menuitems.length; i++) {
          final icon = find.byIcon(menuitems[i].iconData);
          final destination = (navBarRoutes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
        int randomIndex = Random().nextInt(menuitems.length);
        menuitems.add(items[randomIndex]);
        navBarRoutes[navBarRoutes.length] = routes[randomIndex]!;
        await tester.pumpAndSettle();
        for (int i = 0; i < menuitems.length; i++) {
          final icon = find.byIcon(menuitems[i].iconData);
          final destination = (navBarRoutes[i]!['/']).runtimeType.typeX();
          expect(icon, findsOneWidget);
          await tester.tap(icon);
          await tester.pumpAndSettle();
          expect(destination, findsOneWidget);
        }
      });

      testWidgets('NavbarType.material3: default index must be zero',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          type: NavbarType.material3,
        ));
        expect(NavbarNotifier.currentIndex, 0);
        final destination = (routes[0]!['/']).runtimeType.typeX();
        expect(destination, findsOneWidget);
        final icon = find.byIcon(items[0].iconData);
        expect(icon, findsOneWidget);
      });

      testWidgets('NavbarType.material3: Set initial index to non-zero',
          (WidgetTester tester) async {
        int initialIndex = 2;
        await tester.pumpWidget(
            boilerplate(type: NavbarType.material3, index: initialIndex));
        expect(NavbarNotifier.currentIndex, initialIndex);
        final destination = (routes[initialIndex]!['/']).runtimeType.typeX();
        expect(destination, findsOneWidget);
        final icon = find.byIcon(items[initialIndex].iconData);
        expect(icon, findsOneWidget);
      });

      testWidgets(
          'NavbarType.material3: should switch to Navigation Rail in Desktop mode',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          type: NavbarType.material3,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(M3NavBar), findsOneWidget);
        await tester.pumpWidget(boilerplate(isDesktop: true));
        await tester.pumpAndSettle();
        expect(find.byType(NavigationRail), findsOneWidget);
        expect(find.byType(M3NavBar), findsNothing);
      });
    });

    group('NavbarType.material3: should respect BackButtonBehavior', () {
      Future<void> changeNavbarDestination(
          WidgetTester tester, Widget destination, IconData iconData) async {
        final icon = find.byIcon(iconData);
        final destinationType = destination.runtimeType.typeX();
        expect(icon, findsOneWidget);
        await tester.tap(icon);
        await tester.pumpAndSettle();
        expect(destinationType, findsOneWidget);
      }

      Future<void> navigateToNestedTarget(
          WidgetTester tester, Finder tapTarget, Widget destination) async {
        expect(tapTarget, findsOneWidget);
        await tester.tap(tapTarget);
        await tester.pumpAndSettle();
        final destinationFinder = (destination).runtimeType.typeX();
        expect(destinationFinder, findsOneWidget);
      }

      Future<void> triggerBackButton(WidgetTester tester) async {
        final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
        await widgetsAppState.didPopRoute();
        await tester.pumpAndSettle();
      }

      testWidgets(
          'NavbarType.material3: should exit app when at the root of the Navigator stack(default)',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
          type: NavbarType.material3,
        ));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(M3NavBar), findsOneWidget);

        /// verify feeds is the current destination
        await changeNavbarDestination(
            tester, routes[0]!['/']!, items[0].iconData);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, items[1].iconData);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 0".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, items[2].iconData);

        /// Navigate to ProfileEdit
        await navigateToNestedTarget(
            tester, (Icons.edit).iconX(), routes[2]![ProfileEdit.route]!);

        await triggerBackButton(tester);
        expect(
            routes[2]![UserProfile.route].runtimeType.typeX(), findsOneWidget);

        /// This will exit the app
        await triggerBackButton(tester);
        expect(exitCode, 0);
      });
      testWidgets('NavbarType.material3: should remember navigation history',
          (WidgetTester tester) async {
        await tester.pumpWidget(boilerplate(
            type: NavbarType.material3,
            behavior: BackButtonBehavior.rememberHistory));
        await tester.pumpAndSettle();

        expect(find.byType(NavigationRail), findsNothing);
        expect(find.byType(M3NavBar), findsOneWidget);

        /// verify feeds is the current destination
        await changeNavbarDestination(
            tester, routes[0]!['/']!, items[0].iconData);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, items[1].iconData);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 0".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, items[2].iconData);

        /// Navigate to ProfileEdit
        await navigateToNestedTarget(
            tester, (Icons.edit).iconX(), routes[2]![ProfileEdit.route]!);

        expect(NavbarNotifier.stackHistory, equals([0, 1, 2]));

        await triggerBackButton(tester);
        await triggerBackButton(tester);
        expect(NavbarNotifier.stackHistory, equals([0, 1]));

        await triggerBackButton(tester);
        await triggerBackButton(tester);
        await triggerBackButton(tester);
        expect(NavbarNotifier.stackHistory, equals([0]));
      });
    });

    group('NavbarType.material3: Should Pop routes Programmatically', () {
      testWidgets('Navbar should pop route programmatically',
          (WidgetTester tester) async {
        int index = 1;
        await tester.pumpWidget(boilerplate(
          type: NavbarType.material3,
        ));
        await tester.pumpAndSettle();
        final productIcon = find.byIcon(items[index].iconData);
        final productDestination = (routes[index]!['/']).runtimeType.typeX();
        expect(productIcon, findsOneWidget);
        await tester.tap(productIcon);
        await tester.pumpAndSettle();
        expect(productDestination, findsOneWidget);

        /// Navigate to ProductDetail

        await tester.tap("Product 0".textX());
        await tester.pumpAndSettle();
        final productDetail =
            (routes[1]![ProductDetail.route]).runtimeType.typeX();
        expect(productDetail, findsOneWidget);
        NavbarNotifier.popRoute(index);
        await tester.pumpAndSettle();
        expect(productDetail, findsNothing);
        expect(productDestination, findsOneWidget);
      });

      testWidgets('Navbar should pop to base route programmatically',
          (WidgetTester tester) async {
        int index = 1;
        await tester.pumpWidget(boilerplate(
          type: NavbarType.material3,
        ));
        await tester.pumpAndSettle();
        final productIcon = find.byIcon(items[index].iconData);
        final productDestination = (routes[index]!['/']).runtimeType.typeX();
        expect(productIcon, findsOneWidget);
        await tester.tap(productIcon);
        await tester.pumpAndSettle();
        expect(productDestination, findsOneWidget);

        /// Navigate to ProductDetail

        await tester.tap("Product 0".textX());
        await tester.pumpAndSettle();
        final productDetail =
            (routes[1]![ProductDetail.route]).runtimeType.typeX();
        expect(productDetail, findsOneWidget);

        /// Navigate to Product comments

        await tester.tap("show comments".textX());
        await tester.pumpAndSettle();
        final productComments =
            (routes[1]![ProductComments.route]).runtimeType.typeX();
        expect(productComments, findsOneWidget);
        NavbarNotifier.popAllRoutes(index);
        await tester.pumpAndSettle();

        expect(productComments, findsNothing);
        expect(productDetail, findsNothing);
        expect(productDestination, findsOneWidget);
      });
    });
  });

  testWidgets('NavbarType can be changed during runtime',
      (WidgetTester tester) async {
    NavbarType type = NavbarType.notched;
    await tester.pumpWidget(boilerplate(type: type));
    final finder = find.byType(NotchedNavBar);
    expect(finder, findsOneWidget);
    type = NavbarType.standard;
    await tester.pumpWidget(boilerplate(type: type));
    final finder2 = find.byType(BottomNavigationBar);
    expect(finder2, findsOneWidget);
    expect(finder, findsNothing);
  });

  testWidgets('Navbar can be hidden during runtime',
      (WidgetTester tester) async {
    await tester.pumpWidget(boilerplate());
    final finder = find.byType(BottomNavigationBar);
    expect(finder, findsOneWidget);
    NavbarNotifier.hideBottomNavBar = true;
    await tester.pumpAndSettle();
    // test if widget is hidden (not visible in view port)
    expect(finder.hitTestable(), findsNothing);
    NavbarNotifier.hideBottomNavBar = false;
    await tester.pumpAndSettle();
    expect(finder, findsOneWidget);
  });

  testWidgets('Notify index Change', (WidgetTester tester) async {
    int index = 0;
    await tester.pumpWidget(boilerplate());
    NavbarNotifier.addIndexChangeListener((x) {
      index = x;
    });
    NavbarNotifier.index = 1;
    expect(index, 1);
    NavbarNotifier.index = 2;
    expect(index, 2);
    NavbarNotifier.removeLastListener();
    NavbarNotifier.index = 3;
    expect(index, 2);
  });

  group('Snackbar should be controlled using NavbarNotifier:', () {
    testWidgets('Snackbar should be shown', (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.byType(SnackBar), findsNothing);
      final BuildContext context = tester.element(find.byType(NavbarRouter));
      NavbarNotifier.showSnackBar(context, "This is a Snackbar message");
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Snackbar should be hidden', (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.byType(SnackBar), findsNothing);
      final BuildContext context = tester.element(find.byType(NavbarRouter));
      NavbarNotifier.showSnackBar(context, "This is a Snackbar message",
          duration: const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      NavbarNotifier.hideSnackBar(context);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Snackbar should hide after duration',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.byType(SnackBar), findsNothing);
      final BuildContext context = tester.element(find.byType(NavbarRouter));
      NavbarNotifier.showSnackBar(context, "This is a Snackbar message",
          duration: const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets("Snackbar should be closed with closeIcon", (tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.byType(SnackBar), findsNothing);
      final BuildContext context = tester.element(find.byType(NavbarRouter));
      NavbarNotifier.showSnackBar(
        context,
        "This is a Snackbar message",
        duration: const Duration(seconds: 5),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets("Snackbar action label should be tappable", (tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.byType(SnackBar), findsNothing);
      final BuildContext context = tester.element(find.byType(NavbarRouter));
      NavbarNotifier.showSnackBar(
        context,
        "This is a Snackbar message",
        actionLabel: "Tap me",
        onActionPressed: () {
          NavbarNotifier.hideSnackBar(context);
        },
        duration: const Duration(seconds: 5),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      await tester.tap(find.text("Tap me"));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
