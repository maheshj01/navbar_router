// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print

import 'dart:math';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:navbar_router/navbar_router.dart';
import 'package:navbar_router/src/gestures.dart';
import 'package:navbar_router/src/navbar_swipeable_utls.dart';

part 'animated_navbar.dart';

class Destination {
  /// Named route associaed with this destination.
  String route;

  /// must have a initial route `/`
  Widget widget;

  Destination({required this.route, required this.widget});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Destination &&
        other.route == route &&
        other.widget.runtimeType == widget.runtimeType;
  }

  @override
  int get hashCode => route.hashCode ^ widget.hashCode;
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DestinationRouter &&
        listEquals(other.destinations, destinations) &&
        other.initialRoute == initialRoute &&
        other.navbarItem == navbarItem;
  }

  @override
  int get hashCode =>
      destinations.hashCode ^ initialRoute.hashCode ^ navbarItem.hashCode;
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

/// Enum for the Android's Back button behavior
enum BackButtonBehavior {
  /// When the current NavbarItem is at the root of the navigation stack,
  /// pressing the Back button will trigger app exit, which can be handled in [onBackButtonPressed].
  exit,

  /// When the selected NavbarItem is at the root of the navigation stack,
  /// pressing the Back button will switch to the previous NavbarItem based on the stack History of navbar.
  rememberHistory
}

class NavbarRouter extends StatefulWidget {
  /// The destination to show when the user taps the [NavbarItem]
  /// destination also defines the list of Nested destination sand the navbarItem associated with it
  final List<DestinationRouter> destinations;

  /// Route to show the user when the user tried to navigate to a route that
  /// does not exist in the [destinations]
  final WidgetBuilder errorBuilder;

  /// This callback is invoked, when the user taps the back button
  /// on Android.
  /// Defines whether it is the root Navigator or not
  /// if the method returns true then the Navigator is at the base of the navigator stack
  final bool Function(bool)? onBackButtonPressed;

  /// whether the navbar should pop to base route of current tab
  /// when the selected navbarItem is tapped all the routes from that navigator are popped.
  /// feature similar to Instagram's navigation bar
  /// defaults to true.
  final bool shouldPopToBaseRoute;

  /// AnimationDuration in milliseconds for the destination animation
  /// defaults to 300 milliseconds
  final int destinationAnimationDuration;

  /// defaults to Curves.fastOutSlowIn
  final Curve destinationAnimationCurve;

  /// The decoraton for Navbar has all the properties you would expect in a [BottomNavigationBar]
  /// to adjust the style of the Navbar.
  final NavbarDecoration? decoration;

  /// if true, navbar will be shown on the left, this property
  /// can be used along with `NavbarDecoration.isExtended` to make the navbar
  ///  adaptable for large screen sizes.
  /// defaults to false.
  final bool isDesktop;

  /// callback when the currentIndex changes
  final Function(int)? onChanged;

  // callback when the same tab is clicked
  final Function()? onCurrentTabClicked;

  /// The type of the [Navbar] that is to be rendered.
  /// defaults to [NavbarType.standard] which is a standard [BottomNavigationBar]
  ///
  /// Alternatively, you can use [NavbarType.notched] which is a Navbar with a notch
  ///
  /// Use appropriate [NavbarDecoration] for the type of [NavbarType] you are using.
  /// For
  /// NavbarType.standard use [NavbarDecoration]
  /// NavbarType.notched use [NotchedDecoration]
  final NavbarType type;

  /// Whether the back button pressed should pop the current route and switch to the previous route,
  /// defaults to true.
  /// if false, the back button will trigger app exit.
  /// This is applicable only for Android's back button.
  final BackButtonBehavior backButtonBehavior;

  /// Navbar item that is initially selected
  /// defaults to the first item in the list of [NavbarItems]
  final int initialIndex;

  /// Set to true will hide the badges when the tap on the navbar icon.
  final bool hideBadgeOnPageChanged;

  /// Set to true will opt-in to horizontally swipeable navigation bar.
  final bool swipeable;

  /// Configure the swipeable area on the of the screen
  ///
  /// By default, it will be: left center aligned, width = 50 pixels, top = 50 pixels, height = 0.8 x screen height
  ///
  /// Only take effect if **[swipeable]** is set to true
  final Rect? swipeableArea;

  /// Take a look at the [readme](https://github.com/maheshmnj/navbar_router) for more information on how to use this package.
  ///
  /// Please help me improve this package.
  /// Found a bug? Please file an issue [here](https://github.com/maheshmnj/navbar_router/issues/new?assignees=&labels=&template=bug_report.md&title=)
  /// or
  /// File a feature request by clicking [here](https://github.com/maheshmnj/navbar_router/issues/new?assignees=&labels=&template=feature_request.md&title=)
  ///
  ///
  const NavbarRouter(
      {Key? key,
      this.swipeable = false,
      this.swipeableArea,
      required this.destinations,
      required this.errorBuilder,
      this.shouldPopToBaseRoute = true,
      this.onChanged,
      this.decoration,
      this.isDesktop = false,
      this.initialIndex = 0,
      this.type = NavbarType.standard,
      this.destinationAnimationCurve = Curves.fastOutSlowIn,
      this.destinationAnimationDuration = 300,
      this.backButtonBehavior = BackButtonBehavior.exit,
      this.onCurrentTabClicked,
      this.hideBadgeOnPageChanged = true,
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
  late List<AnimationController> fadeAnimation;
  List<GlobalKey<NavigatorState>> keys = [];
  late Gesture pageGesture;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    NavbarNotifier.length = widget.destinations.length;
    // init badge
    List<NavbarBadge> badges = [];
    for (int i = 0; i < NavbarNotifier.length; i++) {
      final navbaritem = widget.destinations[i].navbarItem;
      keys.add(GlobalKey<NavigatorState>());
      items.add(navbaritem);
      badges.add(navbaritem.badge);
    }
    NavbarNotifier.setKeys(keys);

    // set badge list here
    NavbarNotifier.setBadges(badges);
    NavbarNotifier.hideBadgeOnPageChanged = widget.hideBadgeOnPageChanged;

    // re-enable the initial badge that was hidden on setting NavbarNotifier.index
    NavbarNotifier.makeBadgeVisible(NavbarNotifier.currentIndex, true);
    initAnimation();
    NavbarNotifier.index = widget.initialIndex;

    // necessary init for swipeable
    pageGesture = Gesture(context: context, getPadding: getPadding);
    pageGesture.pageController =
        PageController(initialPage: widget.initialIndex);

    NavbarNotifier.addIndexChangeListener(
      (newIndex) {
        if (!mounted) return;
        // print(newIndex);

        if (widget.swipeable) {
          pageGesture.pageController.animateTo(
              pageGesture.getPixelsFromPage(newIndex),
              duration: Durations.long1,
              curve: Curves.ease);
        } else {
          pageGesture.pageController.jumpTo(
            pageGesture.getPixelsFromPage(newIndex),
          );
        }
      },
    );
  }

  void updateWidget() {
    items.clear();
    NavbarNotifier.length = widget.destinations.length;
    for (int i = 0; i < NavbarNotifier.length; i++) {
      final navbaritem = widget.destinations[i].navbarItem;
      items.add(navbaritem);
    }
  }

  void initAnimation() {
    fadeAnimation = items.map<AnimationController>((NavbarItem item) {
      return AnimationController(
          vsync: this,
          value: item == items[widget.initialIndex] ? 1.0 : 0,
          duration:
              Duration(milliseconds: widget.destinationAnimationDuration));
    }).toList();
    fadeAnimation[widget.initialIndex].value = 1.0;
  }

  void clearInitialization() {
    keys.clear();
    items.clear();
    NavbarNotifier.clear();
  }

  @override
  void dispose() {
    for (var controller in fadeAnimation) {
      controller.dispose();
    }
    clearInitialization();
    NavbarNotifier.removeAllListeners();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant NavbarRouter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destinationAnimationCurve !=
            oldWidget.destinationAnimationCurve ||
        widget.destinationAnimationDuration !=
            oldWidget.destinationAnimationDuration) {
      initAnimation();
    }
    if (widget.destinations.length != oldWidget.destinations.length ||
        widget.type != oldWidget.type ||
        !listEquals(oldWidget.destinations, widget.destinations)) {
      updateWidget();
    }
  }

  double getPadding() {
    if (widget.isDesktop) {
      if (NavbarNotifier.isNavbarHidden) {
        return 0;
      }
      if (widget.decoration!.isExtended) {
        return widget.decoration!.minExtendedWidth;
      } else {
        return widget.decoration!.minWidth;
      }
    }
    return 0;
  }

  double bottomPadding() {
    switch (widget.type) {
      case NavbarType.standard:
        return 0;
      case NavbarType.notched:
        return 0;
      case NavbarType.material3:
        return 0;
      case NavbarType.floating:
        return 0;
      default:
        return 0;
    }
  }

  Widget _buildIndexedStackItem(int index, BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation[index],
      builder: (context, child) {
        return IgnorePointer(
          ignoring: index != NavbarNotifier.currentIndex,
          child: Opacity(opacity: fadeAnimation[index].value, child: child),
        );
      },
      child: Navigator(
          key: keys[index],
          initialRoute: widget.destinations[index].initialRoute,
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder? builder = widget.errorBuilder;
            final nestedLength = widget.destinations[index].destinations.length;
            for (int j = 0; j < nestedLength; j++) {
              if (widget.destinations[index].destinations[j].route ==
                  settings.name) {
                builder = (BuildContext _) =>
                    widget.destinations[index].destinations[j].widget;
              }
            }
            return MaterialPageRoute(builder: builder!, settings: settings);
          }),
    );
  }

  void _handleFadeAnimation() {
    for (int i = 0; i < fadeAnimation.length; i++) {
      if (i == NavbarNotifier.currentIndex) {
        fadeAnimation[i].forward();
      } else {
        fadeAnimation[i].reverse();
      }
    }
  }

  // Swipeable page

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }
          final bool isExitingApp = NavbarNotifier.onBackButtonPressed(
              behavior: widget.backButtonBehavior);
          widget.onBackButtonPressed!(isExitingApp);

          // callback onchange when going back the route stack
          if (widget.backButtonBehavior == BackButtonBehavior.rememberHistory &&
              widget.onChanged != null) {
            widget.onChanged!(NavbarNotifier.currentIndex);
          }
          _handleFadeAnimation();
        },
        child: AnimatedBuilder(
            animation: _navbarNotifier,
            builder: (context, child) {
              _handleFadeAnimation();
              return Stack(
                children: [
                  AnimatedPadding(
                    /// same duration as [_AnimatedNavbar]'s animation duration
                    duration: const Duration(milliseconds: 500),
                    padding: EdgeInsets.only(left: getPadding()),
                    child: ListView.builder(
                        itemCount: NavbarNotifier.length,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        controller: pageGesture.pageController,
                        itemBuilder: (context, i) {
                          // use keep-alive to prevent list builder to rebuild
                          return KeepAliveWrapper(
                            keepAlive: true,
                            child: NotificationListener<OverscrollNotification>(
                                onNotification: widget.swipeable
                                    ? pageGesture.handleOverscroll
                                    : null,
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width -
                                        getPadding(),
                                    child: _buildIndexedStackItem(i, context))),
                          );
                        }),
                  ),
                  Positioned(
                    left: 0,
                    top: widget.isDesktop ? 0 : null,
                    bottom: bottomPadding(),
                    right: widget.isDesktop ? null : 0,
                    child: _AnimatedNavBar(
                        model: _navbarNotifier,
                        isDesktop: widget.isDesktop,
                        decoration: widget.decoration,
                        navbarType: widget.type,
                        onItemTapped: (x) {
                          // User pressed  on the same tab twice
                          if (NavbarNotifier.currentIndex == x) {
                            if (widget.shouldPopToBaseRoute) {
                              NavbarNotifier.popAllRoutes(x);
                            }
                            if (widget.onCurrentTabClicked != null) {
                              widget.onCurrentTabClicked!();
                            }
                            if (widget.hideBadgeOnPageChanged) {
                              NavbarNotifier.makeBadgeVisible(
                                  NavbarNotifier.currentIndex, false);
                            }
                          } else {
                            NavbarNotifier.index = x;
                            if (widget.onChanged != null) {
                              widget.onChanged!(x);
                            }
                            _handleFadeAnimation();
                          }
                        },
                        menuItems: items),
                  ),

                  // swipe area
                  Positioned.fromRect(
                    rect: !widget.swipeable
                        ? Rect.zero
                        : widget.swipeableArea ??
                            Rect.fromLTWH(
                                getPadding(),
                                kDragAreaTop,
                                kDragAreaWidth,
                                MediaQuery.of(context).size.width *
                                    kDragAreaHeightFactor),
                    child: GestureDetector(
                      key: const ObjectKey("swipe-left"),
                      behavior: HitTestBehavior.translucent,
                      onHorizontalDragStart: (details) {
                        if (!mounted) return;

                        pageGesture.onDragStart(details);
                      },
                      onHorizontalDragUpdate: (details) {
                        if (!mounted) return;

                        var newOffset = pageGesture.onDragUpdate(details);
                        if (newOffset == null) return;

                        for (int i = 0; i < fadeAnimation.length; i++) {
                          if (i != NavbarNotifier.currentIndex) {
                            var distanceFromCurrentPage =
                                pageGesture.getPixelsFromPage(
                                        NavbarNotifier.currentIndex) -
                                    newOffset;

                            fadeAnimation[i].value = min(
                                1.0,
                                distanceFromCurrentPage.abs() /
                                    (MediaQuery.of(context).size.width -
                                        getPadding()));
                          } else {
                            fadeAnimation[i].value = (newOffset /
                                    pageGesture.getPixelsFromPage(
                                        NavbarNotifier.currentIndex))
                                .clamp(0.5, 1);
                          }
                        }
                      },
                      onHorizontalDragEnd: (details) {
                        if (!mounted) {
                          pageGesture.dragging = false;
                          return;
                        }

                        var value = pageGesture.onDragEnd(details);
                        if (value >= 0 && value < NavbarNotifier.length) {
                          NavbarNotifier.index = value;
                          if (widget.onChanged != null) {
                            widget.onChanged!(value);
                          }
                          _handleFadeAnimation();
                        }
                      },
                    ),
                  ),

                  // swipe right area
                  // Positioned.fromRect(
                  //   key: const ObjectKey("swipe-right"),
                  //   rect: !widget.swipeable
                  //       ? Rect.zero
                  //       : widget.swipeableRightArea ??
                  //           Rect.fromLTWH(
                  //               MediaQuery.of(context).size.width -
                  //                   kDragAreaWidth,
                  //               kDragAreaTop,
                  //               kDragAreaWidth,
                  //               MediaQuery.of(context).size.height *
                  //                   kDragAreaHeightFactor),
                  //   child: GestureDetector(
                  //     behavior: HitTestBehavior.translucent,
                  //     onHorizontalDragStart: (details) {
                  //       onDragStart(details);
                  //     },
                  //     onHorizontalDragUpdate: (details) {
                  //       onDragUpdate(details);
                  //     },
                  //     onHorizontalDragEnd: (details) {
                  //       onDragEnd(details);
                  //     },
                  //   ),
                  // )
                ],
              );
            }));
  }
}

final NavbarNotifier _navbarNotifier = NavbarNotifier();
List<Color> colors = [mediumPurple, Colors.orange, Colors.teal];
const Color mediumPurple = Color.fromRGBO(79, 0, 241, 1.0);
