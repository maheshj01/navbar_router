import 'dart:io';
import 'dart:math';

import 'package:badges/badges.dart' as badges;
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
  // updated test items with badges
  const List<NavbarItem> items = [
    NavbarItem(Icons.home_outlined, 'Home',
        backgroundColor: mediumPurple,
        selectedIcon: Icon(
          key: Key("HomeIconSelected"),
          Icons.home,
          size: 26,
        ),
        badge: NavbarBadge(
          key: Key("TwoDigitBadge"),
          badgeText: "10",
          showBadge: true,
        )),
    NavbarItem(Icons.shopping_bag_outlined, 'Products',
        backgroundColor: Colors.orange,
        selectedIcon: Icon(
          Icons.shopping_bag,
          key: Key("ProductsIconSelected"),
          size: 26,
        ),
        badge: NavbarBadge(
          key: Key("OneDigitBadge"),
          badgeText: "8",
          showBadge: true,
        )),
    NavbarItem(Icons.person_outline, 'Me',
        backgroundColor: Colors.teal,
        selectedIcon: Icon(
          key: Key("MeIconSelected"),
          Icons.person,
          size: 26,
        ),
        badge: NavbarBadge(
          key: Key("DotBadge1"),
          showBadge: true,
          color: Colors.amber,
        )),
    NavbarItem(Icons.settings_outlined, 'Settings',
        backgroundColor: Colors.red,
        selectedIcon: Icon(
          Icons.settings,
          size: 26,
        ),
        badge: NavbarBadge(
          key: Key("DotBadge2"),
          showBadge: true,
          color: Colors.red,
        )),
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
    3: {
      '/': Settings(),
    },
  };

  Widget boilerplate(
      {bool isDesktop = false,
      Size? size,
      BackButtonBehavior behavior = BackButtonBehavior.exit,
      Map<int, Map<String, Widget>> navBarRoutes = routes,
      NavbarType type = NavbarType.standard,
      NavbarDecoration? decoration,
      int index = 0,
      Function()? onCurrentTabClicked,
      Function(int)? onChanged,
      List<NavbarItem> navBarItems = items}) {
    size ??= const Size(800.0, 600.0);
    return MaterialApp(
      home: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
              data: MediaQueryData(size: size),
              child: NavbarRouter(
                errorBuilder: (context) {
                  return const Center(child: Text('Error 404'));
                },
                onChanged: onChanged,
                onCurrentTabClicked: onCurrentTabClicked,
                onBackButtonPressed: (isExiting) {
                  return isExiting;
                },
                initialIndex: index,
                type: type,
                backButtonBehavior: behavior,
                isDesktop: isDesktop,
                destinationAnimationCurve: Curves.fastOutSlowIn,
                destinationAnimationDuration: 200,
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

  Future<void> changeNavbarDestination(
      WidgetTester tester, Widget destination, Finder finder) async {
    final destinationType = destination.runtimeType.typeX();
    expect(finder, findsOneWidget);
    await tester.tap(finder);
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

  // function containing all badge tests and subtests
  badgeGroupTest({NavbarType type = NavbarType.standard}) {
    badges.Badge findBadge(tester, index) {
      return tester.widget(find.byKey(NavbarNotifier.badges[index].key!))
          as badges.Badge;
    }

    // test color and visibility
    testDot(tester, index) {
      expect(find.byKey(NavbarNotifier.badges[index].key!), findsOneWidget);

      // test visibility
      expect(findBadge(tester, index).showBadge,
          NavbarNotifier.badges[index].showBadge);

      // test color
      expect(findBadge(tester, index).badgeStyle.badgeColor,
          NavbarNotifier.badges[index].color);
    }

    /// Test badge
    testBadgeWithText(tester, index) {
      var textFind = find.text(NavbarNotifier.badges[index].badgeText);
      expect(textFind, findsOneWidget);

      // test dot
      testDot(tester, index);

      // compare the content of badge
      Text text = tester.firstWidget(textFind);
      expect(text.data, NavbarNotifier.badges[index].badgeText);
    }

    desktopMode(tester) async {
      await tester.pumpWidget(boilerplate(isDesktop: true, type: type));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
    }

    testBadge(tester, index) async {
      NavbarNotifier.badges[index].badgeText.isNotEmpty
          ? testBadgeWithText(tester, index)
          : testDot(tester, index);
      NavbarNotifier.badges[index].badgeText.isNotEmpty
          ? testBadgeWithText(tester, index)
          : testDot(tester, index);
    }

    testWidgets('Should build initial badges', (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      // test visibility
      testBadge(tester, 0);
      testBadge(tester, 1);
      testBadge(tester, 2);
      testBadge(tester, 3);
    });

    testWidgets('Should allow to update badges dynamically',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());

      // test badge
      testBadge(tester, 0);
      // update the whole badge
      NavbarNotifier.updateBadge(
          0,
          const NavbarBadge(
            key: Key("TwoDigitBadgeNew"),
            badgeText: "11",
            showBadge: true,
          ));
      await tester.pumpAndSettle();

      testBadge(tester, 0);

      // hide the badge
      NavbarNotifier.makeBadgeVisible(0, false);
      await tester.pumpAndSettle();
      expect(NavbarNotifier.badges[0].showBadge, false);
      testBadge(tester, 0);
    });

    testWidgets('Should allow to hide/show badges on demand',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());

      // test badge
      testBadge(tester, 0);

      // hide all the badge
      for (int i = 0; i < NavbarNotifier.length; i++) {
        NavbarNotifier.makeBadgeVisible(i, false);
        await tester.pumpAndSettle();
        expect(NavbarNotifier.badges[i].showBadge, false);
        testBadge(tester, i);
      }

      // show all the badge
      for (int i = 0; i < NavbarNotifier.length; i++) {
        NavbarNotifier.makeBadgeVisible(i, true);
        await tester.pumpAndSettle();
        expect(NavbarNotifier.badges[i].showBadge, true);
        testBadge(tester, i);
      }
    });

    testWidgets('Desktop: should build initial badges',
        (WidgetTester tester) async {
      await desktopMode(tester);
      // test visibility
      testBadge(tester, 0);
      testBadge(tester, 1);
      testBadge(tester, 2);
      testBadge(tester, 3);
    });

    testWidgets('Desktop: should allow to update badges dynamically',
        (WidgetTester tester) async {
      await desktopMode(tester);

      // test badge
      testBadge(tester, 0);
      // update the whole badge
      NavbarNotifier.updateBadge(
          0,
          const NavbarBadge(
            key: Key("TwoDigitBadgeNew"),
            badgeText: "11",
            showBadge: true,
          ));
      await tester.pumpAndSettle();

      testBadge(tester, 0);

      // hide the badge
      NavbarNotifier.makeBadgeVisible(0, false);
      await tester.pumpAndSettle();
      expect(NavbarNotifier.badges[0].showBadge, false);
      testBadge(tester, 0);
    });

    testWidgets('Desktop: should allow to hide/show badges on demand',
        (WidgetTester tester) async {
      await desktopMode(tester);

      // test badge
      testBadge(tester, 0);

      // hide all the badge
      for (int i = 0; i < NavbarNotifier.length; i++) {
        NavbarNotifier.makeBadgeVisible(i, false);
        await tester.pumpAndSettle();
        expect(NavbarNotifier.badges[i].showBadge, false);
        testBadge(tester, i);
      }

      // show all the badge
      for (int i = 0; i < NavbarNotifier.length; i++) {
        NavbarNotifier.makeBadgeVisible(i, true);
        await tester.pumpAndSettle();
        expect(NavbarNotifier.badges[i].showBadge, true);
        testBadge(tester, i);
      }
    });
  }

  group('Test NavbarType: NavbarType.standard ', () {
    // test badges
    group('Should build destination, navbar items, and badges', () {
      testWidgets('NavbarType.standard: should build destinations',
          (WidgetTester tester) async {
        final bottomNavigation = (BottomNavigationBar).typeX();
        final navigationRail = (NavigationRail).typeX();
        int initialIndex = 0;

        await tester.pumpWidget(boilerplate(index: initialIndex));
        await tester.pumpAndSettle();
        expect(navigationRail, findsNothing);
        expect(bottomNavigation, findsOneWidget);
        for (int i = 0; i < items.length; i++) {
          final icon = find.byIcon(items[i].iconData);
          final selectedIcon = find.byKey(const Key('HomeIconSelected'));
          final destination = (routes[i]!['/']).runtimeType.typeX();
          if (i == initialIndex) {
            expect(selectedIcon, findsOneWidget);
            await tester.tap(selectedIcon);
          } else {
            expect(icon, findsOneWidget);
            await tester.tap(icon);
          }
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

      group('NavbarType.standard: badges test', () {
        badgeGroupTest();
      });

      testWidgets(
          "NavbarType.standard: should allow updating navbar routes dynamically ",
          (WidgetTester tester) async {
        List<NavbarItem>? menuitems = [
          const NavbarItem(Icons.home_outlined, 'Home',
              backgroundColor: mediumPurple),
          const NavbarItem(Icons.shopping_bag_outlined, 'Products',
              backgroundColor: Colors.orange),
          const NavbarItem(Icons.person_outline, 'Me',
              backgroundColor: Colors.teal),
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
      final icon = find.byKey(const Key('HomeIconSelected'));
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
      final icon = find.byWidget(items[initialIndex].selectedIcon!);
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
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        await changeNavbarDestination(tester, routes[0]!['/']!, selectedIcon);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        final productsIcon = find.byIcon(items[1].iconData);
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, productsIcon);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 2".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        final profileIcon = find.byIcon(items[2].iconData);
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, profileIcon);

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
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        await changeNavbarDestination(tester, routes[0]!['/']!, selectedIcon);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        final productsIcon = find.byIcon(items[1].iconData);
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, productsIcon);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 2".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        final profileIcon = find.byIcon(items[2].iconData);
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, profileIcon);

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

    // This
      // testWidgets('back button should trigger IndexChangeListener',
      //     (WidgetTester tester) async {
      //   int index = 0;
      //   await tester.pumpWidget(boilerplate());
      //   NavbarNotifier.addIndexChangeListener((x) {
      //     index = x;
      //   });
      //   NavbarNotifier.index = 1;
      //   expect(index, 1);
      //   expect(NavbarNotifier.stackHistory, equals([0, 1]));
      //   await triggerBackButton(tester);
      //   expect(index, 0);
      //   expect(NavbarNotifier.stackHistory, equals([0]));
      //   NavbarNotifier.removeLastListener();
      //   NavbarNotifier.index = 3;
      //   expect(index, 2);
      //   expect(NavbarNotifier.stackHistory, equals([0, 2]));
      // });
    });

    group('NavbarType.standard: Should Pop routes Programmatically', () {
      testWidgets('Navbar should push route programmatically',
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
        expect('Product 1'.textX(), findsOneWidget);
        String tapTargetText =
            'Tap to push a route on HomePage Programmatically';
        expect(tapTargetText.textX(), findsOneWidget);
        await tester.tap(tapTargetText.textX());
        await tester.pumpAndSettle();
        expect('switching to Home'.textX(), findsNWidgets(items.length));
        expect(find.byType(SnackBar), findsNWidgets(items.length));
        await tester.pumpAndSettle(const Duration(seconds: 4));
        final feedRoute = routes[0]!['/'].runtimeType.typeX();
        final feedDetailRoute =
            routes[0]![FeedDetail.route]!.runtimeType.typeX();
        expect(feedDetailRoute, findsOneWidget);
        expect(feedRoute, findsNothing);
      });

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

        await tester.tap("Product 1".textX());
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

        await tester.tap("Product 2".textX());
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

    testWidgets('NavbarDecoration can be set to NavigationRail in Desktop mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate(
          isDesktop: true,
          decoration: NavbarDecoration(
            minExtendedWidth: 200,
            isExtended: true,
            navbarType: BottomNavigationBarType.shifting,
            backgroundColor: Colors.blue,
            elevation: 8.0,
            indicatorColor: Colors.grey,
            indicatorShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            minWidth: 74,
          )));

      await tester.pumpAndSettle();
      final navigationRail = (NavigationRail).typeX();
      expect(navigationRail, findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      final finder = find.byType(StandardNavbar);
      expect(finder, findsNothing);
      final NavigationRail navigationRailWidget =
          tester.widget(navigationRail) as NavigationRail;
      expect(navigationRailWidget.extended, true);
      expect(navigationRailWidget.minExtendedWidth, 200);
      expect(navigationRailWidget.backgroundColor, Colors.blue);
      expect(navigationRailWidget.elevation, 8.0);
      expect(navigationRailWidget.indicatorColor, Colors.grey);
      expect(
          navigationRailWidget.indicatorShape,
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ));
      expect(navigationRailWidget.minWidth, 74);
    });
  });

  /// Test navbar type notched

  testWidgets('Navbar should programmatically change index',
      (WidgetTester tester) async {
    await tester.pumpWidget(boilerplate());
    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(0));
    expect('Feed 0 card'.textX(), findsOneWidget);
    NavbarNotifier.index = 1;
    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(1));
    expect('Product 1'.textX(), findsOneWidget);
    NavbarNotifier.index = 2;
    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(2));
    expect('Hi! This is your Profile Page'.textX(), findsOneWidget);
    // NavbarNotifier.index = 3;
    // await tester.pumpAndSettle();
    // expect(NavbarNotifier.currentIndex, equals(3));
    // expect('Slide to change theme color'.textX(), findsOneWidget);
  });

  group('Test NavbarType: NavbarType.notched ', () {
    group('NavbarType.notched: should build destination and navbar items', () {
      group('Badges test', () {
        badgeGroupTest(type: NavbarType.notched);
      });

      testWidgets('navbar_router should build destinations',
          (WidgetTester tester) async {
        final navbar = (NotchedNavBar).typeX();
        final navigationRail = (NavigationRail).typeX();
        int initialIndex = 0;
        await tester.pumpWidget(
            boilerplate(type: NavbarType.notched, index: initialIndex));
        await tester.pumpAndSettle();
        expect(navigationRail, findsNothing);
        expect(navbar, findsOneWidget);

        for (int i = 0; i < items.length; i++) {
          final icon = find.byIcon(items[i].iconData);
          final selectedIcon = find.byKey(const Key('HomeIconSelected'));
          final destination = (routes[i]!['/']).runtimeType.typeX();
          if (i == initialIndex) {
            expect(selectedIcon, findsOneWidget);
            await tester.tap(selectedIcon);
          } else {
            expect(icon, findsOneWidget);
            await tester.tap(icon);
          }
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
          const NavbarItem(Icons.home_outlined, 'Home',
              backgroundColor: mediumPurple),
          const NavbarItem(Icons.shopping_bag_outlined, 'Products',
              backgroundColor: Colors.orange),
          const NavbarItem(Icons.person_outline, 'Me',
              backgroundColor: Colors.teal),
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
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        expect(selectedIcon, findsOneWidget);
      });

      testWidgets('NavbarType.notched: Set initial index to non-zero',
          (WidgetTester tester) async {
        int initialIndex = 2;
        await tester.pumpWidget(
            boilerplate(type: NavbarType.notched, index: initialIndex));
        expect(NavbarNotifier.currentIndex, initialIndex);
        final destination = (routes[initialIndex]!['/']).runtimeType.typeX();
        expect(destination, findsOneWidget);
        final icon = find.byWidget(items[initialIndex].selectedIcon!);
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
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        await changeNavbarDestination(tester, routes[0]!['/']!, selectedIcon);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        final productsIcon = find.byIcon(items[1].iconData);
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, productsIcon);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 2".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        final profileIcon = find.byIcon(items[2].iconData);
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, profileIcon);

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
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        await changeNavbarDestination(tester, routes[0]!['/']!, selectedIcon);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        final productsIcon = find.byIcon(items[1].iconData);
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, productsIcon);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 2".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        final profileIcon = find.byIcon(items[2].iconData);
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, profileIcon);

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

        await tester.tap("Product 2".textX());
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

        await tester.tap("Product 2".textX());
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
      group('Badges test', () {
        badgeGroupTest(type: NavbarType.material3);
      });
      testWidgets('navbar_router should build destinations',
          (WidgetTester tester) async {
        final navbar = (M3NavBar).typeX();
        final navigationRail = (NavigationRail).typeX();
        int initialIndex = 0;
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        await tester.pumpWidget(boilerplate(
          type: NavbarType.material3,
        ));
        await tester.pumpAndSettle();
        expect(navigationRail, findsNothing);
        expect(navbar, findsOneWidget);

        for (int i = 0; i < items.length; i++) {
          final icon = find.byIcon(items[i].iconData);
          final destination = (routes[i]!['/']).runtimeType.typeX();
          if (i == initialIndex) {
            expect(selectedIcon, findsOneWidget);
            await tester.tap(selectedIcon);
          } else {
            expect(icon, findsOneWidget);
            await tester.tap(icon);
          }
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
          const NavbarItem(Icons.home_outlined, 'Home',
              backgroundColor: mediumPurple),
          const NavbarItem(Icons.shopping_bag_outlined, 'Products',
              backgroundColor: Colors.orange),
          const NavbarItem(Icons.person_outline, 'Me',
              backgroundColor: Colors.teal),
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
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        expect(selectedIcon, findsOneWidget);
      });

      testWidgets('NavbarType.material3: Set initial index to non-zero',
          (WidgetTester tester) async {
        int initialIndex = 2;
        await tester.pumpWidget(
            boilerplate(type: NavbarType.material3, index: initialIndex));
        expect(NavbarNotifier.currentIndex, initialIndex);
        final destination = (routes[initialIndex]!['/']).runtimeType.typeX();
        expect(destination, findsOneWidget);
        final icon = find.byWidget(items[initialIndex].selectedIcon!);
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
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        await changeNavbarDestination(tester, routes[0]!['/']!, selectedIcon);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        final productIcon = find.byIcon(items[1].iconData);
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, productIcon);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 2".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile

        final profileIcon = find.byIcon(items[2].iconData);
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, profileIcon);

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
        final selectedIcon = find.byKey(const Key('HomeIconSelected'));
        await changeNavbarDestination(tester, routes[0]!['/']!, selectedIcon);

        /// Navigate to FeedDetail
        await navigateToNestedTarget(
            tester, "Feed 0 card".textX(), routes[0]![FeedDetail.route]!);

        /// Change index to products
        final productIcon = find.byIcon(items[1].iconData);
        await changeNavbarDestination(
            tester, routes[1]![ProductList.route]!, productIcon);

        /// Navigate to ProductDetail
        await navigateToNestedTarget(
            tester, "Product 2".textX(), routes[1]![ProductDetail.route]!);

        /// Navigate to Product comments
        await navigateToNestedTarget(tester, "show comments".textX(),
            routes[1]![ProductComments.route]!);

        /// Change index to profile
        final profileIcon = find.byIcon(items[2].iconData);
        await changeNavbarDestination(
            tester, routes[2]![UserProfile.route]!, profileIcon);

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

        await tester.tap("Product 2".textX());
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

        await tester.tap("Product 2".textX());
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

  testWidgets('decoration can be set to M3 Navbar', (tester) async {
    await tester.pumpWidget(boilerplate(
        type: NavbarType.material3,
        decoration: M3NavbarDecoration(
          elevation: 10,
          height: 100,
          indicatorColor: Colors.red,
          indicatorShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          isExtended: false,
          labelTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          backgroundColor: Colors.red,
        )));
    final finder = find.byType(M3NavBar);
    expect(finder, findsOneWidget);
    final M3NavBar navbar = finder.evaluate().first.widget as M3NavBar;
    expect(navbar.decoration.elevation, 10);
    expect(navbar.decoration.height, 100);
    expect(navbar.decoration.indicatorColor, Colors.red);
    expect(
        navbar.decoration.indicatorShape.runtimeType, RoundedRectangleBorder);
    expect(
        navbar.decoration.labelBehavior,

        /// NavigationDestinationLabelBehavior.alwaysShow is the default
        NavigationDestinationLabelBehavior.alwaysShow);
    expect(navbar.decoration.isExtended, false);
    expect(navbar.decoration.backgroundColor, Colors.red);
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

  testWidgets("onCurrentTabClicked should be invoked", (tester) async {
    int index = 0;
    await tester.pumpWidget(boilerplate(
      onCurrentTabClicked: () {
        index = 1;
      },
    ));
    await tester.pumpAndSettle();
    final productIcon = find.byIcon(items[1].iconData);
    expect(productIcon, findsOneWidget);
    await tester.tap(productIcon);
    expect(index, 0);
    await tester.pumpAndSettle();
    final productSelectedIcon = find.byKey(const Key("ProductsIconSelected"));
    expect(productSelectedIcon, findsOneWidget);
    await tester.tap(productSelectedIcon);
    expect(index, 1);
  });

  testWidgets("onChanged callback should be invoked on Index change",
      (tester) async {
    int index = 0;
    await tester.pumpWidget(boilerplate(
      onChanged: (x) {
        index = x;
      },
    ));
    await tester.pumpAndSettle();
    final productIcon = find.byIcon(items[1].iconData);
    final homeIcon = find.byIcon(items[0].iconData);
    expect(productIcon, findsOneWidget);
    await tester.tap(productIcon);
    expect(index, 1);
    await tester.pumpAndSettle();
    await tester.tap(homeIcon);
    await tester.pumpAndSettle();
    expect(index, 0);
  });

  // WARNING: Snackbar Test are written considering snackbars are shown across all the tabs
  // e.g if a snackbar is shown it will be displayed items.length times
  // This is because we have migrated to Stack inplace of IndexedStack
  group('Snackbar should be controlled using NavbarNotifier:', skip: false, () {
    testWidgets('Snackbar should be shown', (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.byType(SnackBar), findsNothing);
      final BuildContext context = tester.element(find.byType(NavbarRouter));
      NavbarNotifier.showSnackBar(context, "This is a Snackbar message");
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNWidgets(items.length));
    });

    testWidgets('Snackbar should be hidden', (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.byType(SnackBar), findsNothing);
      final BuildContext context = tester.element(find.byType(NavbarRouter));
      NavbarNotifier.showSnackBar(context, "This is a Snackbar message",
          duration: const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNWidgets(items.length));
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
      expect(find.byType(SnackBar), findsNWidgets(items.length));
      await tester.pumpAndSettle(const Duration(seconds: 4));
      expect(find.byType(SnackBar), findsNWidgets(items.length));
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
      expect(find.byType(SnackBar), findsNWidgets(items.length));
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets("Snackbar onClosed should be invoked", (tester) async {
      await tester.pumpWidget(boilerplate());
      expect(find.byType(SnackBar), findsNothing);
      final BuildContext context = tester.element(find.byType(NavbarRouter));
      bool isClosed = false;
      NavbarNotifier.showSnackBar(
        context,
        "This is a Snackbar message",
        duration: const Duration(seconds: 5),
        onClosed: () {
          isClosed = true;
        },
      );
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNWidgets(items.length));
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(isClosed, true);
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
      expect(find.byType(SnackBar), findsNWidgets(items.length));
      await tester.tap(find.text("Tap me").first);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('Test NavbarType: NavbarType.floating', () {
    group('Badges test', () {
      badgeGroupTest(type: NavbarType.floating);
    });
    testWidgets('NavbarType can be changed during runtime', (tester) async {
      NavbarType type = NavbarType.notched;
      await tester.pumpWidget(boilerplate(type: type));
      final finder = find.byType(NotchedNavBar);
      expect(finder, findsOneWidget);
      type = NavbarType.floating;
      await tester.pumpWidget(boilerplate(type: type));
      final finder2 = find.byType(FloatingNavbar);
      expect(finder2, findsOneWidget);
      expect(finder, findsNothing);
    });

    testWidgets('Navbar can be hidden during runtime',
        (WidgetTester tester) async {
      await tester.pumpWidget(boilerplate(type: NavbarType.floating));
      final finder = find.byType(FloatingNavbar);
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
      await tester.pumpWidget(boilerplate(type: NavbarType.floating));
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

    testWidgets('decoration can be set to Floating Navbar', (tester) async {
      await tester.pumpWidget(boilerplate(
          type: NavbarType.floating,
          decoration: FloatingNavbarDecoration(
            borderRadius: BorderRadius.circular(20),
            backgroundColor: Colors.red,
            selectedIconColor: Colors.green,
            unselectedIconColor: Colors.blue,
            margin: const EdgeInsets.all(10),
          )));
      final finder = find.byType(FloatingNavbar);
      expect(finder, findsOneWidget);
      final floatingNavbar = tester.widget<FloatingNavbar>(finder);
      expect(floatingNavbar.borderRadius, BorderRadius.circular(20));
      expect(floatingNavbar.decoration.backgroundColor, Colors.red);
      expect(floatingNavbar.decoration.selectedIconColor, Colors.green);
      expect(floatingNavbar.decoration.unselectedIconColor, Colors.blue);
      expect(floatingNavbar.decoration.margin, const EdgeInsets.all(10));
    });
  });

  testWidgets('Navbar should persist index on widget update',
      (WidgetTester tester) async {
    // pass outlined icons
    Color backgroundColor = Colors.red;
    List<NavbarItem> navItems = [
      NavbarItem(Icons.home_outlined, 'Home',
          backgroundColor: backgroundColor,
          selectedIcon: const Icon(
            key: Key("HomeIconSelected"),
            Icons.home_outlined,
            size: 26,
          )),
      const NavbarItem(Icons.shopping_bag_outlined, 'Products',
          backgroundColor: Colors.orange,
          selectedIcon: Icon(
            Icons.shopping_bag_outlined,
            key: Key("ProductsIconSelected"),
            size: 26,
          )),
      const NavbarItem(Icons.person_outline, 'Me',
          backgroundColor: Colors.teal,
          selectedIcon: Icon(
            key: Key("MeIconSelected"),
            Icons.person,
            size: 26,
          )),
      const NavbarItem(Icons.settings_outlined, 'Settings',
          backgroundColor: Colors.red,
          selectedIcon: Icon(
            Icons.settings,
            size: 26,
          )),
    ];
    await tester.pumpWidget(boilerplate(navBarItems: navItems));

    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(0));
    expect('Feed 0 card'.textX(), findsOneWidget);
    NavbarNotifier.index = 1;
    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(1));
    expect('Product 1'.textX(), findsOneWidget);
    NavbarNotifier.index = 2;
    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(2));
    expect('Hi! This is your Profile Page'.textX(), findsOneWidget);

    // change background color
    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(2));
    backgroundColor = Colors.green;
    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(2));
  });

  testWidgets('NavbarItem properties can be changed during runtime',
      (tester) async {
    Color backgroundColor = Colors.red;
    List<NavbarItem> navItems = [
      NavbarItem(Icons.home_outlined, 'Home',
          backgroundColor: backgroundColor,
          selectedIcon: const Icon(
            key: Key("HomeIconSelected"),
            Icons.home_outlined,
            size: 26,
          )),
      const NavbarItem(Icons.shopping_bag_outlined, 'Products',
          backgroundColor: Colors.orange,
          selectedIcon: Icon(
            Icons.shopping_bag_outlined,
            key: Key("ProductsIconSelected"),
            size: 26,
          )),
      const NavbarItem(Icons.person_outline, 'Me',
          backgroundColor: Colors.teal,
          selectedIcon: Icon(
            key: Key("MeIconSelected"),
            Icons.person,
            size: 26,
          )),
      const NavbarItem(Icons.settings_outlined, 'Settings',
          backgroundColor: Colors.red,
          selectedIcon: Icon(
            Icons.settings,
            size: 26,
          )),
    ];
    await tester.pumpWidget(boilerplate(navBarItems: navItems));
    await tester.pumpAndSettle();
    expect(NavbarNotifier.currentIndex, equals(0));
    expect((navItems[2].selectedIcon as Icon).color, isNull);
    navItems[2] = const NavbarItem(Icons.person_outline, 'Me',
        backgroundColor: Colors.teal,
        selectedIcon: Icon(
          key: Key("MeIconSelected"),
          Icons.person,
          color: Colors.green,
          size: 26,
        ));

    await tester.pumpAndSettle();
    expect((navItems[2].selectedIcon as Icon).color, Colors.green);
  });
}
