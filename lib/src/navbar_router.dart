import 'dart:async';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

part 'animated_navbar.dart';

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

  /// if true, navbar will be shown on the left, this property
  /// can be used along with `NavbarDecoration.isExtended` to make the navbar
  ///  adaptable for large screen sizes.
  final bool isDesktop;

  /// callback when the currentIndex changes
  final Function(int)? onChanged;

  const NavbarRouter(
      {Key? key,
      required this.destinations,
      required this.errorBuilder,
      this.shouldPopToBaseRoute = true,
      this.onChanged,
      this.decoration,
      this.isDesktop = true,
      this.destinationAnimationCurve = Curves.fastOutSlowIn,
      this.destinationAnimationDuration = 1700,
      this.onBackButtonPressed})
      : assert(destinations.length >= 2,
            "Destinations length must be greater than or equal to 2"),
        super(key: key);

  @override
  State<NavbarRouter> createState() => _NavbarRouterState();
}

class _NavbarRouterState extends State<NavbarRouter>
    with TickerProviderStateMixin {
  final List<NavbarItem> items = [];
  // late Animation<double> fadeAnimation;
  // late AnimationController _controller;
  List<GlobalKey<NavigatorState>> keys = [];
  late int length;
  @override
  void initState() {
    super.initState();

    /// AnimationController for the Destination Animation

    initialize();
    for (int i = 0; i < length; i++) {
      final _controller = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 400),
          reverseDuration: Duration(milliseconds: 600));
      _controller.value = 1.0;
      _controllers.add(_controller);
    }
    // fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
    //   CurvedAnimation(
    //       parent: _controller, curve: widget.destinationAnimationCurve),
    // );
  }

  void initialize() {
    length = widget.destinations.length;
    for (int i = 0; i < length; i++) {
      final navbaritem = widget.destinations[i].navbarItem;
      keys.add(GlobalKey<NavigatorState>());
      items.add(navbaritem);
    }

    NavbarNotifier.setKeys(keys);
    // _controller.forward();
  }

  void clearInitialization() {
    // _controller.reset();
    keys.clear();
    items.clear();
  }

  @override
  void dispose() {
    clearInitialization();
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NavbarRouter oldWidget) {
    /// update animation
    // if (widget.destinationAnimationCurve !=
    //         oldWidget.destinationAnimationCurve ||
    //     widget.destinationAnimationDuration !=
    //         oldWidget.destinationAnimationDuration) {
    // _controller.duration =
    //     Duration(milliseconds: widget.destinationAnimationDuration);
    // fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
    //   CurvedAnimation(
    //       parent: _controller, curve: widget.destinationAnimationCurve),
    // );
    // }

    if (widget.destinations.length != oldWidget.destinations.length) {
      length = widget.destinations.length;
      clearInitialization();
      initialize();
    }
    super.didUpdateWidget(oldWidget);
  }

  double getPadding() {
    if (widget.isDesktop) {
      if (widget.decoration!.isExtended) {
        return 256.0;
      } else {
        return 72.0;
      }
    }
    return 0;
  }

  void _animateDestinations() {
    // _controller.reset();
    // _controller.forward();
  }

  List<AnimationController> _controllers = [];
  @override
  Widget build(BuildContext context) {
    List<Widget> _buildChildren() {
      final List<Widget> children = [];
      for (int i = 0; i < length; i++) {
        if (i == NavbarNotifier.currentIndex) {
          _controllers[i].forward();
        } else {
          _controllers[i].reverse();
        }
        children.add(IgnorePointer(
          ignoring: NavbarNotifier.currentIndex != i,
          child: FadeTransition(
            opacity:
                _controllers[i].drive(CurveTween(curve: Curves.fastOutSlowIn)),
            child: Navigator(
                key: keys[i],
                initialRoute: widget.destinations[i].initialRoute,
                onGenerateRoute: (RouteSettings settings) {
                  WidgetBuilder? builder = widget.errorBuilder;
                  final nestedLength =
                      widget.destinations[i].destinations.length;
                  for (int j = 0; j < nestedLength; j++) {
                    if (widget.destinations[i].destinations[j].route ==
                        settings.name) {
                      builder = (BuildContext _) =>
                          widget.destinations[i].destinations[j].widget;
                    }
                  }
                  return MaterialPageRoute(
                      builder: builder!, settings: settings);
                }),
          ),
        ));
      }
      return children;
    }

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
                      padding: EdgeInsets.only(left: getPadding()),
                      child: IndexedStack(
                          index: NavbarNotifier.currentIndex,
                          children: _buildChildren()),
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
                              // _animateDestinations();
                              if (widget.onChanged != null) {
                                widget.onChanged!(x);
                              }
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

Future<void> navigate(BuildContext context, String route,
        {bool isDialog = false,
        bool isRootNavigator = true,
        Map<String, dynamic>? arguments}) =>
    Navigator.of(context, rootNavigator: isRootNavigator)
        .pushNamed(route, arguments: arguments);

final NavbarNotifier _navbarNotifier = NavbarNotifier();
List<Color> colors = [mediumPurple, Colors.orange, Colors.teal];
const Color mediumPurple = Color.fromRGBO(79, 0, 241, 1.0);
