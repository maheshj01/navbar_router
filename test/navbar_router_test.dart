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
                backButtonBehavior: behavior,
                isDesktop: isDesktop,
                destinationAnimationCurve: Curves.fastOutSlowIn,
                destinationAnimationDuration: 600,
                decoration: NavbarDecoration(
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

  group('navbar_router should build destination and navbar items', () {
    testWidgets('navbar_router should build destinations',
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

    testWidgets('navbar should build navbarItem labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.text(items[0].text), findsOneWidget);
      expect(find.text(items[1].text), findsWidgets);
      expect(find.text(items[2].text), findsOneWidget);
    });

    testWidgets("Navbar should allow updating navbar routes dynamically ",
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
  testWidgets('navbar_router default index must be zero',
      (WidgetTester tester) async {
    await tester.pumpWidget(boilerplate());
    expect(NavbarNotifier.currentIndex, 0);
    final destination = (routes[0]!['/']).runtimeType.typeX();
    expect(destination, findsOneWidget);
    final icon = find.byIcon(items[0].iconData);
    expect(icon, findsOneWidget);
  });

  testWidgets('Navbar should switch to Navigation Rail in Desktop mode',
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

  group('navbar should respect BackButtonBehavior', () {
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
      await navigateToNestedTarget(
          tester, "show comments".textX(), routes[1]![ProductComments.route]!);

      /// Change index to profile
      await changeNavbarDestination(
          tester, routes[2]![UserProfile.route]!, items[2].iconData);

      /// Navigate to ProfileEdit
      await navigateToNestedTarget(
          tester, (Icons.edit).iconX(), routes[2]![ProfileEdit.route]!);

      await triggerBackButton(tester);
      expect(routes[2]![UserProfile.route].runtimeType.typeX(), findsOneWidget);

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
      await navigateToNestedTarget(
          tester, "show comments".textX(), routes[1]![ProductComments.route]!);

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

  group('Pop routes Programmatically', () {
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
}
