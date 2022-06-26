import 'dart:async';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:navbar_router/src/navbar_notifier.dart';

class Destination {
  // Named route associaed with this destination.
  String route;

  // must have a initial route `/`
  Widget widget;

  Destination({required this.route, required this.widget});
}

class DestinationRouter {

  /// The Nested destinations to show when the [navbarItem] is selected
  final List<Destination> destinations;

  /// Route to load when the app is started
  /// for the current destination, defaults to '/'
  ///  initial route must be present in List of destinations
  final String initialRoute;

  /// The NavbarItem associated with this destination
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
  /// The type of the Navbar to be displayed
  /// [BottomNavigationBarType.fixed] or [BottomNavigationBarType.shifting]
  final BottomNavigationBarType? navbarType;

  /// The backgroundColor of the Navbar
  final Color? backgroundColor;

  /// The color of the selected item
  final Color? selectedItemColor;

  /// The color of the unselected item
  final Color? unselectedItemColor;

  /// The elevation shadown on the edges of bottomnavigationbar
  final double? elevation;

  /// The color of the selected item icon
  final Color? iconColor;

  /// The color of the label text
  final Color? labelColor;

  /// The color of the unselected item icon
  final Color? unselectedIconColor;

  /// Whether or not to show the unselected label text
  final bool? showUnselectedLabels;

  /// The color of the unselected label text
  final Color? unselectedLabelColor;

  /// The color of the selected item icon
  final Color? selectedIconColor;

  /// The color of the label text
  final Color? selectedLabelColor;

  /// whether or not to show the selected label text
  final bool? showSelectedLabels;

  /// defaults to 24.0
  final double? iconSize;

  /// haptic feedbakc when the item is selected
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
  /// destination also defines the list of Nested destination sand the navbarItem associated with it
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

  // whether or not navbar should be responsive
  final bool isDesktop;

  const NavbarRouter(
      {Key? key,
      required this.destinations,
      required this.errorBuilder,
      this.shouldPopToBaseRoute = true,
      this.decoration,
      this.isDesktop = true,
      this.destinationAnimationCurve = Curves.fastOutSlowIn,
      this.destinationAnimationDuration = 700,
      this.onBackButtonPressed})
      : assert(destinations.length >= 2,
            "Destinations length must be greater than or equal to 2"),
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
    initialize();
  }

  void initialize() {
    length = widget.destinations.length;
    for (int i = 0; i < length; i++) {
      final navbaritem = widget.destinations[i].navbarItem;
      keys.add(GlobalKey<NavigatorState>());
      items.add(navbaritem);
    }

    NavbarNotifier.setKeys(keys);
    _controller.forward();
  }

  void clearInitialization() {
    _controller.reset();
    keys.clear();
    items.clear();
  }

  @override
  void dispose() {
    clearInitialization();
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

    if (widget.destinations.length != oldWidget.destinations.length) {
      length = widget.destinations.length;
      clearInitialization();
      initialize();
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
                    AnimatedPadding(
                      /// same duration as [_AnimatedNavbar]'s animation duration
                      duration: const Duration(milliseconds: 500),
                      padding: EdgeInsets.only(
                          left:
                              widget.isDesktop && !NavbarNotifier.isNavbarHidden
                                  ? 72
                                  : 0),
                      child: IndexedStack(
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
                                    WidgetBuilder? builder =
                                        widget.errorBuilder;
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
                    ),
                    Positioned(
                      left: 0,
                      top: widget.isDesktop ? 0 : null,
                      bottom: 0,
                      right: widget.isDesktop ? null : 0,
                      child: _AnimatedNavBar(
                          model: _navbarNotifier,
                          isDesktop: widget.isDesktop,
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

  /// IconData for the navbar item
  final IconData iconData;

  /// label for the navbar item
  final String text;

  /// background color for the navbar item whnen type is [NavbarType.shifting]
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

class _AnimatedNavBar extends StatefulWidget {
  const _AnimatedNavBar(
      {Key? key,
      this.decoration,
      required this.model,
      this.isDesktop = false,
      required this.menuItems,
      required this.onItemTapped})
      : super(key: key);
  final List<NavbarItem> menuItems;
  final NavbarNotifier model;
  final Function(int) onItemTapped;
  final bool isDesktop;
  final NavbarDecoration? decoration;

  @override
  _AnimatedNavBarState createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<_AnimatedNavBar>
    with SingleTickerProviderStateMixin {
  @override
  void didUpdateWidget(covariant _AnimatedNavBar oldWidget) {
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
            offset: widget.isDesktop
                ? Offset(-animation.value, 0)
                : Offset(0, animation.value),
            child: widget.isDesktop
                ? NavigationRail(
                    onDestinationSelected: (x) {
                      widget.onItemTapped(x);
                    },
                    backgroundColor: widget.decoration?.backgroundColor,
                    destinations: widget.menuItems.map((NavbarItem menuItem) {
                      return NavigationRailDestination(
                        icon: Icon(menuItem.iconData),
                        label: Text(menuItem.text),
                      );
                    }).toList(),
                    selectedIndex: NavbarNotifier.currentIndex)
                : Container(
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
                      showUnselectedLabels:
                          widget.decoration?.showUnselectedLabels,
                      selectedItemColor: widget.decoration?.selectedItemColor,
                      elevation: widget.decoration?.elevation,
                      iconSize: widget.decoration?.iconSize ?? 24.0,
                      unselectedItemColor:
                          widget.decoration?.unselectedItemColor,
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
