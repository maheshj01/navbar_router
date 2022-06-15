import 'dart:async';
import 'package:flutter/material.dart';
import 'package:navbar_router/src/navbar_notifier.dart';

class Destination {
  String route;

  /// must have a initial route `/`
  Widget widget;

  Destination({required this.route, required this.widget});
}

class DestinationRouter {
  final List<Destination> destinations;

  /// Route to load when the app is started
  /// for the current destination, defaults to '/'
  ///  initial route must be present in List of destinations
  final String initialRoute;

  final NavbarItem navbarItem;

  DestinationRouter(
      {required this.destinations,
      required this.navbarItem,
      this.initialRoute = '/'})
      : assert(_isRoutePresent(initialRoute, destinations),
            'Initial route must be present in List of Destinations');
}

/// helper class for assert
bool _isRoutePresent(String route, List<Destination> destinations) {
  bool isPresent = false;
  for (Destination destination in destinations) {
    if (destination.route == route) {
      isPresent = true;
      return isPresent;
    }
  }
  return isPresent;
}

class NavbarDecoration {
  final BottomNavigationBarType? navbarType;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;
  final Color? iconColor;
  final Color? labelColor;
  final Color? unselectedIconColor;
  final bool? showUnselectedLabels;
  final Color? unselectedLabelColor;
  final Color? selectedIconColor;
  final Color? selectedLabelColor;
  final bool? showSelectedLabels;

  /// defaults to 24.0
  final double? iconSize;
  final bool? enableFeedback;

  NavbarDecoration({
    this.navbarType,
    this.backgroundColor,
    this.elevation,
    this.enableFeedback,
    this.iconColor,
    this.iconSize,
    this.labelColor,
    this.selectedItemColor,
    this.showSelectedLabels,
    this.showUnselectedLabels = true,
    this.unselectedItemColor,
    this.selectedIconColor,
    this.selectedLabelColor,
    this.unselectedIconColor,
    this.unselectedLabelColor,
  });
}

class NavbarRouter extends StatefulWidget {
  /// The destination to show when the user taps the [NavbarItem]
  final List<DestinationRouter> destinations;

  /// Route to show the user when the user tried to navigate to a route that
  /// does not exist in the [destinations]
  final WidgetBuilder errorBuilder;

  /// Defines whether it is the root Navigator or not
  /// if the method returns true then the Navigator is at the base of the navigator stack
  final bool Function(bool)? onBackButtonPressed;

  /// whether the navbar should pop all routes except first
  /// when the current navbar is tapped while the route is deeply nested
  /// feature similar to Instagram's navigation bar
  /// defaults to true.
  final bool shouldPopToBaseRoute;

  /// AnimationDuration in milliseconds
  final int destinationAnimationDuration;

  /// defaults to Curves.fastOutSlowIn
  final Curve destinationAnimationCurve;

  /// The decoraton for Navbar has all the properties you would expect in a [BottomNavigationBar]
  /// to adjust the style of the Navbar.
  final NavbarDecoration? decoration;

  const NavbarRouter(
      {Key? key,
      required this.destinations,
      required this.errorBuilder,
      this.shouldPopToBaseRoute = true,
      this.decoration,
      this.destinationAnimationCurve = Curves.fastOutSlowIn,
      this.destinationAnimationDuration = 700,
      this.onBackButtonPressed})
      :
        // : assert(destinations.length == items.length,
        //       "Destination and MenuItem list must be of same length"),
        super(key: key);

  @override
  State<NavbarRouter> createState() => _NavbarRouterState();
}

class _NavbarRouterState extends State<NavbarRouter>
    with SingleTickerProviderStateMixin {
  final List<NavbarItem> items = [];
  late Animation<double> fadeAnimation;
  late AnimationController _controller;
  List<GlobalKey<NavigatorState>> keys = [];
  late int length;
  @override
  void initState() {
    super.initState();

    /// AnimationController for the Destination Animation
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.destinationAnimationDuration),
    );
    fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller, curve: widget.destinationAnimationCurve),
    );

    length = widget.destinations.length;

    for (int i = 0; i < length; i++) {
      final navbaritem = widget.destinations[i].navbarItem;
      keys.add(GlobalKey<NavigatorState>());
      items.add(navbaritem);
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
  void didUpdateWidget(covariant NavbarRouter oldWidget) {
    /// update animation
    if (widget.destinationAnimationCurve !=
            oldWidget.destinationAnimationCurve ||
        widget.destinationAnimationDuration !=
            oldWidget.destinationAnimationDuration) {
      _controller.duration =
          Duration(milliseconds: widget.destinationAnimationDuration);
      fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller, curve: widget.destinationAnimationCurve),
      );
    }
    super.didUpdateWidget(oldWidget);
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
                                initialRoute:
                                    widget.destinations[i].initialRoute,
                                onGenerateRoute: (RouteSettings settings) {
                                  WidgetBuilder? builder = widget.errorBuilder;
                                  final nestedLength = widget
                                      .destinations[i].destinations.length;
                                  for (int j = 0; j < nestedLength; j++) {
                                    if (widget.destinations[i].destinations[j]
                                            .route ==
                                        settings.name) {
                                      builder = (BuildContext _) => widget
                                          .destinations[i]
                                          .destinations[j]
                                          .widget;
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
                          decoration: widget.decoration,
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
                          menuItems: items),
                    ),
                  ],
                );
              })),
    );
  }
}

class NavbarItem {
  const NavbarItem(this.iconData, this.text, {this.backgroundColor});
  final IconData iconData;
  final String text;
  final Color? backgroundColor;
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

class AnimatedNavBar extends StatefulWidget {
  const AnimatedNavBar(
      {Key? key,
      this.decoration,
      required this.model,
      required this.menuItems,
      required this.onItemTapped})
      : super(key: key);
  final List<NavbarItem> menuItems;
  final NavbarNotifier model;
  final Function(int) onItemTapped;
  final NavbarDecoration? decoration;

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
                type: widget.decoration?.navbarType,
                currentIndex: NavbarNotifier.currentIndex,
                onTap: (x) {
                  widget.onItemTapped(x);
                },
                backgroundColor: widget.decoration?.backgroundColor,
                showSelectedLabels: widget.decoration?.showSelectedLabels,
                enableFeedback: widget.decoration?.enableFeedback,
                showUnselectedLabels: widget.decoration?.showUnselectedLabels,
                selectedItemColor: widget.decoration?.selectedItemColor,
                elevation: widget.decoration?.elevation,
                iconSize: widget.decoration?.iconSize ?? 24.0,
                unselectedItemColor: widget.decoration?.unselectedItemColor,
                items: widget.menuItems
                    .map((NavbarItem menuItem) => BottomNavigationBarItem(
                          backgroundColor: menuItem.backgroundColor,
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
