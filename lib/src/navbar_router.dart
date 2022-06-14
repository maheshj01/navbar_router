import 'dart:async';
import 'package:flutter/material.dart';
import 'package:navbar_router/src/navbar_notifier.dart';

class Destination {
  String path;

  /// must have a initial route `/`
  Widget widget;

  Destination(this.path, this.widget);
}

class NavbarBuilder extends StatefulWidget {
  /// The destination to show when the user taps the [NavbarItem]
  final List<List<Destination>> destinations;

  /// Route to show the user when the user tried to navigate to a route that
  /// does not exist in the [destinations]
  final WidgetBuilder errorBuilder;

  /// navbar Items to show in the navbar
  final List<NavbarItem> items;

  /// Defines whether it is the root Navigator or not
  /// if the method returns true then the Navigator is at the base of the navigator stack
  final bool Function(bool)? onBackButtonPressed;

  /// whether the navbar should pop all routes except first
  /// when the current navbar is tapped while the route is deeply nested
  /// feature similar to Instagram's navigation bar
  /// defaults to true.
  final bool shouldPopToBaseRoute;

  const NavbarBuilder(
      {Key? key,
      required this.destinations,
      required this.errorBuilder,
      this.shouldPopToBaseRoute = true,
      required this.items,
      this.onBackButtonPressed})
      : assert(destinations.length == items.length,
            "Destination and MenuItem list must be of same length"),
        super(key: key);

  @override
  State<NavbarBuilder> createState() => _NavbarBuilderState();
}

class _NavbarBuilderState extends State<NavbarBuilder>
    with SingleTickerProviderStateMixin {
  final List<BottomNavigationBarItem> _bottomList = [];
  late Animation<double> fadeAnimation;
  late AnimationController _controller;
  List<GlobalKey<NavigatorState>> keys = [];
  late int length;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );
    length = widget.items.length;

    for (int i = 0; i < length; i++) {
      keys.add(GlobalKey<NavigatorState>());
      _bottomList.add(BottomNavigationBarItem(
        icon: Icon(widget.items[i].iconData),
        label: widget.items[i].text,
      ));
    }

    NavbarNotifier.setKeys(keys);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final bool isExitingApp = await NavbarNotifier.onBackButtonPressed();
        final bool value = widget.onBackButtonPressed!(isExitingApp);
        return value;
      },
      child: Material(
          child: AnimatedBuilder(
              animation: _navbarNotifier,
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    IndexedStack(
                      index: NavbarNotifier.currentIndex,
                      children: [
                        for (int i = 0; i < length; i++)
                          FadeTransition(
                            opacity: fadeAnimation,
                            child: Navigator(
                                key: keys[i],
                                initialRoute: '/',
                                onGenerateRoute: (RouteSettings settings) {
                                  WidgetBuilder? builder = widget.errorBuilder;
                                  final nestedLength =
                                      widget.destinations[i].length;
                                  for (int j = 0; j < nestedLength; j++) {
                                    if (widget.destinations[i][j].path ==
                                        settings.name) {
                                      builder = (BuildContext _) =>
                                          widget.destinations[i][j].widget;
                                    }
                                  }
                                  return MaterialPageRoute(
                                      builder: builder!, settings: settings);
                                }),
                          )
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: AnimatedNavBar(
                          model: _navbarNotifier,
                          onItemTapped: (x) {
                            // User pressed  on the same tab twice
                            if (NavbarNotifier.currentIndex == x) {
                              if (widget.shouldPopToBaseRoute) {
                                NavbarNotifier.popAllRoutes(x);
                              }
                            } else {
                              NavbarNotifier.index = x;

                              /// Animated navbar Destinations
                              _controller.reset();
                              _controller.forward();
                            }
                          },
                          menuItems: widget.items),
                    ),
                  ],
                );
              })),
    );
  }
}

class NavbarItem {
  const NavbarItem(this.iconData, this.text);
  final IconData iconData;
  final String text;
}

Future<void> navigate(BuildContext context, String route,
        {bool isDialog = false,
        bool isRootNavigator = true,
        Map<String, dynamic>? arguments}) =>
    Navigator.of(context, rootNavigator: isRootNavigator)
        .pushNamed(route, arguments: arguments);

final NavbarNotifier _navbarNotifier = NavbarNotifier();
List<Color> colors = [mediumPurple, Colors.orange, Colors.teal];
const Color mediumPurple = Color.fromRGBO(79, 0, 241, 1.0);
const String placeHolderText =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

class AnimatedNavBar extends StatefulWidget {
  const AnimatedNavBar(
      {Key? key,
      required this.model,
      required this.menuItems,
      required this.onItemTapped})
      : super(key: key);
  final List<NavbarItem> menuItems;
  final NavbarNotifier model;
  final Function(int) onItemTapped;

  @override
  _AnimatedNavBarState createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant AnimatedNavBar oldWidget) {
    if (NavbarNotifier.isNavbarHidden != isHidden) {
      if (!isHidden) {
        _showBottomNavBar();
      } else {
        _hideBottomNavBar();
      }
      isHidden = !isHidden;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _hideBottomNavBar() {
    _controller.reverse();
    return;
  }

  void _showBottomNavBar() {
    _controller.forward();
    return;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addListener(() => setState(() {}));
    animation = Tween(begin: 0.0, end: 100.0).animate(_controller);
  }

  late AnimationController _controller;
  late Animation<double> animation;
  bool isHidden = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(0, animation.value),
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(2, -2),
                ),
              ]),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.shifting,
                currentIndex: NavbarNotifier.currentIndex,
                onTap: (x) {
                  widget.onItemTapped(x);
                },
                elevation: 16.0,
                showUnselectedLabels: true,
                unselectedItemColor: Colors.white54,
                selectedItemColor: Colors.white,
                items: widget.menuItems
                    .map((NavbarItem menuItem) => BottomNavigationBarItem(
                          backgroundColor: colors[NavbarNotifier.currentIndex],
                          icon: Icon(menuItem.iconData),
                          label: menuItem.text,
                        ))
                    .toList(),
              ),
            ),
          );
        });
  }
}
