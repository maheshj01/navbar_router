part of 'navbar_router.dart';

enum NavbarType { standard, notched, material3, floating }

const double kM3NavbarHeight = 80.0;
const double kStandardNavbarHeight = kBottomNavigationBarHeight;
const double kNotchedNavbarHeight = kBottomNavigationBarHeight * 1.45;
const double kFloatingNavbarHeight = 60.0;

/// The height of the navbar based on the [NavbarType]
double kNavbarHeight = 0.0;

class _AnimatedNavBar extends StatefulWidget {
  const _AnimatedNavBar(
      {Key? key,
      this.decoration,
      required this.model,
      this.isDesktop = false,
      this.navbarType = NavbarType.standard,
      required this.menuItems,
      required this.onItemTapped})
      : super(key: key);
  final List<NavbarItem> menuItems;
  final NavbarNotifier model;
  final Function(int) onItemTapped;
  final bool isDesktop;
  final NavbarType navbarType;
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
    final theme = Theme.of(context);
    final defaultDecoration = NavbarDecoration(
        borderRadius: BorderRadius.circular(20.0),
        selectedIconColor: theme.bottomNavigationBarTheme.selectedItemColor,
        margin: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
            theme.colorScheme.surface,
        elevation: 8,
        showUnselectedLabels: true,
        unselectedIconColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        unselectedLabelColor:
            theme.bottomNavigationBarTheme.unselectedItemColor ??
                theme.primaryColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        unselectedLabelTextStyle:
            theme.bottomNavigationBarTheme.unselectedLabelStyle ??
                const TextStyle(color: Colors.black),
        unselectedIconTheme: theme.iconTheme.copyWith(color: Colors.black),
        selectedIconTheme: theme.iconTheme,
        selectedLabelTextStyle:
            theme.bottomNavigationBarTheme.selectedLabelStyle,
        enableFeedback: true,
        isExtended: true,
        navbarType: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: theme.colorScheme.onBackground);

    NavbarDecoration navigationRailDefaultDecoration = NavbarDecoration(
      backgroundColor: theme.navigationRailTheme.backgroundColor ??
          theme.colorScheme.surface,
      elevation: theme.navigationRailTheme.elevation,
      showUnselectedLabels: true,
      selectedIconTheme: theme.navigationRailTheme.selectedIconTheme,
      enableFeedback: true,
      isExtended: true,
      unselectedIconTheme: theme.navigationRailTheme.unselectedIconTheme,
      selectedLabelTextStyle: theme.navigationRailTheme.selectedLabelTextStyle,
      unselectedLabelTextStyle:
          theme.navigationRailTheme.unselectedLabelTextStyle,
      indicatorShape: theme.navigationRailTheme.indicatorShape,
      indicatorColor: theme.navigationRailTheme.indicatorColor,
      navbarType: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    );

    final foregroundColor =
        defaultDecoration.backgroundColor!.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white;

    NavbarBase buildNavBar() {
      switch (widget.navbarType) {
        case NavbarType.standard:
          kNavbarHeight = kBottomNavigationBarHeight;
          return StandardNavbar(
            index: NavbarNotifier.currentIndex,
            navbarHeight: kBottomNavigationBarHeight,
            navBarDecoration: widget.decoration ?? defaultDecoration,
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            navBarElevation: widget.decoration?.elevation,
          );
        case NavbarType.notched:
          kNavbarHeight = kNotchedNavbarHeight;
          if (widget.decoration != null) {
            final decoration = defaultDecoration.copyWith(
                backgroundColor: widget.decoration!.backgroundColor ??
                    Theme.of(context).primaryColor,
                elevation: widget.decoration!.elevation,
                showUnselectedLabels: widget.decoration!.showUnselectedLabels,
                selectedIconColor: widget.decoration!.selectedIconColor,
                unselectedIconColor: widget.decoration!.unselectedIconColor,
                unselectedLabelColor: widget.decoration!.unselectedLabelColor,
                unselectedItemColor: widget.decoration!.unselectedItemColor,
                unselectedLabelTextStyle:
                    widget.decoration!.unselectedLabelTextStyle,
                unselectedIconTheme: widget.decoration!.unselectedIconTheme,
                selectedIconTheme: widget.decoration!.selectedIconTheme ??
                    theme.iconTheme.copyWith(color: foregroundColor),
                enableFeedback: widget.decoration!.enableFeedback,
                showSelectedLabels: false);
            return NotchedNavBar(
              notchDecoration:
                  NotchedDecoration.fromNavbarDecoration(decoration),
              items: widget.menuItems,
              onTap: widget.onItemTapped,
              color: widget.decoration!.backgroundColor,
              navBarElevation: widget.decoration!.elevation,
              index: NavbarNotifier.currentIndex,
            );
          } else {
            return NotchedNavBar(
              notchDecoration:
                  NotchedDecoration.fromNavbarDecoration(defaultDecoration),
              items: widget.menuItems,
              onTap: widget.onItemTapped,
              color: defaultDecoration.backgroundColor,
              navBarElevation: defaultDecoration.elevation,
              index: NavbarNotifier.currentIndex,
            );
          }
        case NavbarType.material3:
          kNavbarHeight = kM3NavbarHeight;
          if (widget.decoration != null) {
            final decoration0 = defaultDecoration.copyWith(
              isExtended: widget.decoration!.isExtended,
              backgroundColor: widget.decoration!.backgroundColor ??
                  theme.colorScheme.surface,
              elevation: widget.decoration!.elevation,
              height: widget.decoration!.height,
              selectedIconTheme: widget.decoration!.selectedIconTheme ??
                  theme.iconTheme
                      .copyWith(color: theme.colorScheme.onSecondaryContainer),
              indicatorColor: widget.decoration!.indicatorColor ??
                  theme.colorScheme.secondaryContainer,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorShape: widget.decoration!.indicatorShape,
              selectedLabelTextStyle:
                  widget.decoration!.selectedLabelTextStyle ??
                      theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
            );
            return M3NavBar(
              index: NavbarNotifier.currentIndex,
              m3Decoration:
                  M3NavbarDecoration.fromNavbarDecoration(decoration0),
              items: widget.menuItems,
              onTap: widget.onItemTapped,
              navBarElevation: widget.decoration!.elevation,
              labelBehavior: widget.decoration!.labelBehavior!,
              navbarHeight: widget.decoration!.height!,
            );
          } else {
            return M3NavBar(
              index: NavbarNotifier.currentIndex,
              m3Decoration:
                  M3NavbarDecoration.fromNavbarDecoration(defaultDecoration),
              labelBehavior: defaultDecoration.labelBehavior!,
              items: widget.menuItems,
              onTap: widget.onItemTapped,
              navBarElevation: defaultDecoration.elevation,
              navbarHeight: widget.decoration!.height!,
            );
          }
        case NavbarType.floating:
          kNavbarHeight = kFloatingNavbarHeight;

          if (widget.decoration != null) {
            final decoration = defaultDecoration.copyWith(
              borderRadius: widget.decoration!.borderRadius,
              backgroundColor: widget.decoration!.backgroundColor ??
                  theme.colorScheme.surface,
              elevation: widget.decoration!.elevation,
              height: widget.decoration!.height,
              selectedIconColor: widget.decoration!.selectedIconColor,
              unselectedIconColor: widget.decoration!.unselectedIconColor,
              selectedIconTheme: widget.decoration!.selectedIconTheme ??
                  theme.iconTheme.copyWith(color: theme.colorScheme.primary),
              indicatorColor: widget.decoration!.indicatorColor ??
                  theme.colorScheme.secondaryContainer,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorShape: widget.decoration!.indicatorShape,
              margin: widget.decoration!.margin,
              selectedLabelTextStyle:
                  widget.decoration!.selectedLabelTextStyle ??
                      theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
            );
            return FloatingNavbar(
              index: NavbarNotifier.currentIndex,
              navBarDecoration: decoration,
              items: widget.menuItems,
              onTap: widget.onItemTapped,
              margin: widget.decoration!.margin,
              borderRadius: widget.decoration!.borderRadius,
              navBarElevation: widget.decoration!.elevation,
            );
          } else {
            return FloatingNavbar(
              index: NavbarNotifier.currentIndex,
              navBarDecoration: defaultDecoration,
              items: widget.menuItems,
              onTap: widget.onItemTapped,
              borderRadius: widget.decoration!.borderRadius,
              margin: widget.decoration!.margin,
              navBarElevation: defaultDecoration.elevation,
            );
          }

        default:
          return StandardNavbar(
            navBarDecoration: widget.decoration!,
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            navBarElevation: widget.decoration!.elevation,
          );
      }
    }

    Widget buildNavigationRail() {
      if (widget.decoration != null) {
        navigationRailDefaultDecoration =
            navigationRailDefaultDecoration.copyWith(
          isExtended: widget.decoration!.isExtended,
          enableFeedback: widget.decoration!.enableFeedback,
          backgroundColor:
              widget.decoration!.backgroundColor ?? theme.colorScheme.surface,
          elevation: widget.decoration!.elevation ??
              theme.navigationRailTheme.elevation,
          selectedIconTheme: widget.decoration!.selectedIconTheme ??
              theme.iconTheme
                  .copyWith(color: theme.colorScheme.onSecondaryContainer),
          indicatorColor: widget.decoration!.indicatorColor ??
              theme.colorScheme.secondaryContainer,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorShape: widget.decoration!.indicatorShape,
          selectedLabelTextStyle: widget.decoration!.selectedLabelTextStyle ??
              theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
        );
      }

      return NavigationRail(
          elevation: navigationRailDefaultDecoration.elevation,
          onDestinationSelected: (x) {
            widget.onItemTapped(x);
          },
          useIndicator: true,
          indicatorColor: navigationRailDefaultDecoration.indicatorColor ??
              theme.colorScheme.secondaryContainer,
          indicatorShape: navigationRailDefaultDecoration.indicatorShape,
          selectedLabelTextStyle:
              navigationRailDefaultDecoration.selectedLabelTextStyle,
          unselectedLabelTextStyle:
              navigationRailDefaultDecoration.unselectedLabelTextStyle,
          unselectedIconTheme:
              navigationRailDefaultDecoration.unselectedIconTheme,
          selectedIconTheme:
              navigationRailDefaultDecoration.selectedIconTheme ??
                  theme.iconTheme
                      .copyWith(color: theme.colorScheme.onSecondaryContainer),
          extended: navigationRailDefaultDecoration.isExtended,
          backgroundColor: navigationRailDefaultDecoration.backgroundColor ??
              theme.colorScheme.surface,
          destinations: widget.menuItems.map((NavbarItem menuItem) {
            return NavigationRailDestination(
              icon: Icon(menuItem.iconData),
              label: Text(menuItem.text),
            );
          }).toList(),
          selectedIndex: NavbarNotifier.currentIndex);
    }

    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
              offset: widget.isDesktop
                  ? Offset(-animation.value, 0)
                  : Offset(0, animation.value),
              child: widget.isDesktop ? buildNavigationRail() : buildNavBar());
        });
  }
}

abstract class NavbarBase extends StatefulWidget {
  const NavbarBase({Key? key}) : super(key: key);
  NavbarDecoration get decoration;

  double? get elevation;

  Function(int)? get onItemTapped;

  List<NavbarItem> get menuItems;

  double get height;
}

class StandardNavbar extends NavbarBase {
  const StandardNavbar(
      {Key? key,
      required this.navBarDecoration,
      required this.navBarElevation,
      required this.onTap,
      this.navbarHeight,
      this.index = 0,
      required this.items})
      : super(key: key);

  final List<NavbarItem> items;
  final Function(int) onTap;
  final NavbarDecoration navBarDecoration;
  final double? navBarElevation;
  final int index;
  final double? navbarHeight;

  @override
  StandardNavbarState createState() => StandardNavbarState();

  @override
  NavbarDecoration get decoration => navBarDecoration;

  @override
  double? get elevation => navBarElevation;

  @override
  List<NavbarItem> get menuItems => items;

  @override
  Function(int p1)? get onItemTapped => onTap;

  @override
  double get height => navbarHeight ?? kStandardNavbarHeight;
}

class StandardNavbarState extends State<StandardNavbar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + 6,
      child: BottomNavigationBar(
        type: widget.decoration.navbarType,
        currentIndex: NavbarNotifier.currentIndex,
        onTap: (x) {
          widget.onItemTapped!(x);
        },
        backgroundColor: widget.decoration.backgroundColor,
        showSelectedLabels: widget.decoration.showSelectedLabels,
        enableFeedback: widget.decoration.enableFeedback,
        showUnselectedLabels: widget.decoration.showUnselectedLabels,
        elevation: widget.decoration.elevation,
        iconSize: Theme.of(context).iconTheme.size ?? 24.0,
        unselectedItemColor: widget.decoration.unselectedItemColor,
        selectedItemColor: widget.decoration.selectedLabelTextStyle?.color,
        unselectedLabelStyle: widget.decoration.unselectedLabelTextStyle,
        selectedLabelStyle: widget.decoration.selectedLabelTextStyle,
        selectedIconTheme: widget.decoration.selectedIconTheme,
        unselectedIconTheme: widget.decoration.unselectedIconTheme,
        items: widget.menuItems
            .map((NavbarItem menuItem) => BottomNavigationBarItem(
                  backgroundColor: menuItem.backgroundColor,
                  icon: Icon(
                    menuItem.iconData,
                  ),
                  label: menuItem.text,
                ))
            .toList(),
      ),
    );
  }
}

class NotchedNavBar extends NavbarBase {
  const NotchedNavBar(
      {Key? key,
      required this.notchDecoration,
      required this.color,
      required this.navBarElevation,
      required this.onTap,
      this.navbarHeight = kNotchedNavbarHeight,
      this.index = 0,
      required this.items})
      : assert(items.length > 2,
            """NotchedNavBar requires at least 3 items to function properly,
            This is a temporary limitation and will be fixed in the future.
            If you need a navbar with less than 3 items, please use the StandardNavbar widget
            using the NavbarDecoration.navbarType: NavbarType.standard property.
            """),
        super(key: key);

  final List<NavbarItem> items;
  final Function(int) onTap;
  final NotchedDecoration notchDecoration;
  final Color? color;
  final double? navBarElevation;
  final int index;
  final double navbarHeight;

  @override
  NotchedNavBarState createState() => NotchedNavBarState();

  @override
  NotchedDecoration get decoration {
    return notchDecoration;
  }

  @override
  double? get elevation => navBarElevation;

  @override
  List<NavbarItem> get menuItems => items;

  @override
  Function(int p1)? get onItemTapped => onTap;

  @override
  double get height => navbarHeight;
}

class NotchedNavBarState extends State<NotchedNavBar>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _selectedIndex = widget.index;
    _startAnimation();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  late AnimationController? _controller;
  late Animation<double> notchAnimation = CurvedAnimation(
    parent: _controller!,
    curve: const Interval(
      0.0,
      0.8,
      curve: Curves.bounceInOut,
    ),
  );

  late Animation<double> iconAnimation =
      Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(
    parent: _controller!,
    curve: const Interval(
      0.6,
      1.0,
      curve: Curves.easeIn,
    ),
  ));

  late Animation<double> opacityAnimation =
      Tween<double>(begin: 0.2, end: 1).animate(CurvedAnimation(
    parent: _controller!,
    curve: const Interval(
      0.2,
      1.0,
      curve: Curves.easeIn,
    ),
  ));
  late Animation<double> scaleAnimation =
      Tween<double>(begin: 1.0, end: 1.4).animate(CurvedAnimation(
    parent: _controller!,
    curve: const Interval(
      0.6,
      1.0,
      curve: Curves.easeIn,
    ),
  ));

  void _startAnimation() async {
    _controller!.reset();
    _controller!.forward();
  }

  int _selectedIndex = 0;

  @override
  void didUpdateWidget(NotchedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _selectedIndex = widget.index;
      _startAnimation();
    }
  }

  Widget circularButton() {
    return Container(
        height: 60,
        width: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.decoration.backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Icon(
          widget.menuItems[NavbarNotifier.currentIndex].iconData,
          color: widget.decoration.selectedIconColor,
          size: (widget.decoration.selectedIconTheme?.size ?? 24.0) *
              scaleAnimation.value,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final selectedWidget = AnimatedBuilder(
        animation: _controller!,
        builder: (context, snapshot) {
          return Transform.translate(
            offset: Offset(0, -iconAnimation.value),
            child: Opacity(
              opacity: opacityAnimation.value,
              child: SizedBox(
                  height: 58.0,
                  width: 58.0,
                  child: FittedBox(child: circularButton())),
            ),
          );
        });

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          AnimatedBuilder(
              animation: _controller!,
              builder: (context, snapshot) {
                return ClipPath(
                    clipper: NotchedClipper(
                        index: NavbarNotifier.currentIndex,
                        animation: notchAnimation.value),
                    child: Material(
                      color: widget.decoration.backgroundColor,
                      child: SizedBox(
                        height: widget.navbarHeight,
                        width: double.infinity,
                      ),
                    ));
              }),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (int i = 0; i < widget.menuItems.length; i++)
              Expanded(
                  child: _selectedIndex == i
                      ? selectedWidget
                      : InkWell(
                          onTap: () {
                            _selectedIndex = i;
                            widget.onItemTapped!(i);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 80,
                            child: MenuTile(
                              item: widget.menuItems[i],
                              decoration: widget.decoration,
                            ),
                          ),
                        ))
          ]),
        ],
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final NavbarDecoration decoration;
  final NavbarItem item;

  const MenuTile({super.key, required this.item, required this.decoration});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          item.iconData,
          color:
              decoration.unselectedIconColor ?? decoration.unselectedItemColor,
        ),
        const SizedBox(
          height: 6,
        ),
        decoration.showUnselectedLabels
            ? Flexible(
                child:
                    Text(item.text, style: decoration.unselectedLabelTextStyle))
            : const SizedBox.shrink()
      ],
    );
  }
}

// clipper for the notched navbar
class NotchedClipper extends CustomClipper<Path> {
  int index;
  double animation;
  NotchedClipper({this.index = 0, this.animation = 1});
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    double curveRadius = 38.0 * animation;
    const elevationFromEdge = 2.0;

    path.moveTo(0, elevationFromEdge);
    int items = NavbarNotifier.length;
    double iconSize = 24.0;
    double padding = (width - (iconSize * items)) / (items);
    double centerX =
        (index) * padding + (index) * iconSize + iconSize / 2 + padding / 2;

    Offset point1 = Offset(centerX - curveRadius - 20, 0);
    path.lineTo(point1.dx - 40, point1.dy);
    point1 = Offset(point1.dx + 20, -8);
    Offset point2 = Offset(point1.dx, 20);
    path.quadraticBezierTo(point1.dx, point1.dy, point2.dx, point2.dy);
    Offset point3 = Offset(centerX + curveRadius, 20);
    path.arcToPoint(point3,
        radius: const Radius.circular(10), clockwise: false);
    Offset point4 = Offset(point3.dx, -8);
    Offset point5 = Offset(point4.dx + 40, 0);
    path.quadraticBezierTo(point4.dx, point4.dy, point5.dx, point5.dy);
    // center point of the notch curve
    path.lineTo(width, elevationFromEdge);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();
    // rectangle clip
    return path;
  }

  @override
  bool shouldReclip(NotchedClipper oldClipper) => true;
  // oldClipper.index != index;
}

class WaveClipper extends CustomClipper<Path> {
  int index;
  WaveClipper({this.index = 0});
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    path.moveTo(0, height * 0.5);
    path.lineTo(0, height * 0.8);
    path.quadraticBezierTo(
        width * 0.25, height * 0.75, width * 0.5, height * 0.8);
    path.quadraticBezierTo(width * 0.75, height * 0.85, width, height * 0.8);
    path.lineTo(width, height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class M3NavBar extends NavbarBase {
  const M3NavBar({
    Key? key,
    required this.items,
    required this.onTap,
    required this.m3Decoration,
    this.labelBehavior = NavigationDestinationLabelBehavior.alwaysShow,
    this.navBarElevation,
    this.navbarHeight = kM3NavbarHeight,
    required this.index,
  }) : super(key: key);

  final List<NavbarItem> items;
  final Function(int) onTap;
  final M3NavbarDecoration m3Decoration;
  final NavigationDestinationLabelBehavior labelBehavior;
  final double? navBarElevation;
  final int index;
  final double navbarHeight;

  @override
  M3NavBarState createState() => M3NavBarState();

  @override
  NavbarDecoration get decoration => m3Decoration;

  @override
  double? get elevation => navBarElevation;

  @override
  List<NavbarItem> get menuItems => items;

  @override
  Function(int p1)? get onItemTapped => onTap;

  @override
  double get height => navbarHeight;
}

class M3NavBarState extends State<M3NavBar> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          useMaterial3: true,
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: widget.decoration.backgroundColor ??
                Theme.of(context).colorScheme.surface,
            elevation: widget.elevation,
            labelTextStyle: MaterialStateProperty.all(
                widget.decoration.selectedLabelTextStyle),
            indicatorShape: widget.decoration.indicatorShape ??
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
            iconTheme:
                MaterialStateProperty.all(widget.decoration.selectedIconTheme),
            labelBehavior: widget.decoration.showUnselectedLabels
                ? NavigationDestinationLabelBehavior.alwaysShow
                : NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorColor: widget.decoration.indicatorColor,
            height: widget.height,
          )),
      child: NavigationBar(
          height: widget.height,
          backgroundColor: widget.decoration.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          animationDuration: const Duration(milliseconds: 300),
          elevation: widget.elevation,
          indicatorColor: widget.decoration.indicatorColor,
          indicatorShape: widget.decoration.indicatorShape,
          labelBehavior: widget.labelBehavior,
          destinations: widget.items
              .map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: NavigationDestination(
                      tooltip: e.text,
                      icon: Icon(e.iconData),
                      label: e.text,
                      selectedIcon: Icon(e.iconData),
                    ),
                  ))
              .toList(),
          selectedIndex: NavbarNotifier.currentIndex,
          onDestinationSelected: (int index) => widget.onItemTapped!(index)),
    );
  }
}

class FloatingNavbar extends NavbarBase {
  const FloatingNavbar(
      {Key? key,
      required this.navBarDecoration,
      required this.navBarElevation,
      required this.onTap,
      this.navbarHeight = kFloatingNavbarHeight,
      this.index = 0,
      this.margin,
      this.borderRadius,
      required this.items})
      : super(key: key);

  final List<NavbarItem> items;
  final Function(int) onTap;
  final NavbarDecoration navBarDecoration;
  final double? navBarElevation;
  final int index;
  final EdgeInsetsGeometry? margin;
  final double navbarHeight;
  final BorderRadius? borderRadius;

  @override
  FloatingNavbarState createState() => FloatingNavbarState();

  @override
  NavbarDecoration get decoration => navBarDecoration;

  @override
  double? get elevation => navBarElevation;

  @override
  List<NavbarItem> get menuItems => items;

  @override
  Function(int p1)? get onItemTapped => onTap;

  @override
  double get height => navbarHeight;
}

class FloatingNavbarState extends State<FloatingNavbar> {
  late int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.index;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FloatingNavbar oldWidget) {
    if (oldWidget.index != widget.index) {
      _selectedIndex = widget.index;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
        data: Theme.of(context).copyWith(
            useMaterial3: true,
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: widget.decoration.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
              elevation: widget.elevation,
              labelTextStyle: MaterialStateProperty.all(
                  widget.decoration.selectedLabelTextStyle),
              indicatorShape: widget.decoration.indicatorShape ??
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0)),
              iconTheme: MaterialStateProperty.all(
                  widget.decoration.selectedIconTheme),
              labelBehavior: widget.decoration.showUnselectedLabels
                  ? NavigationDestinationLabelBehavior.alwaysShow
                  : NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorColor: widget.decoration.indicatorColor,
              height: widget.height,
            )),
        child: Container(
          height: kFloatingNavbarHeight,
          margin: widget.margin ??
              const EdgeInsets.symmetric(horizontal: 40.0, vertical: 18.0),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ??
                const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
            color: widget.decoration.backgroundColor ??
                Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(3, 4), // hanges position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              for (int i = 0; i < widget.items.length; i++)
                Expanded(
                    child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                      enableFeedback: widget.decoration.enableFeedback,
                      borderRadius:
                          widget.borderRadius ?? BorderRadius.circular(16.0),
                      onTap: () {
                        _selectedIndex = i;
                        widget.onItemTapped!(i);
                      },
                      child: SizedBox(
                        height: kFloatingNavbarHeight,
                        child: Icon(
                          widget.items[i].iconData,
                          size: 26,
                          color: _selectedIndex == i
                              ? widget.decoration.selectedIconColor
                              : widget.decoration.unselectedIconColor,
                        ),
                      )),
                ))
            ],
          ),
        ));
  }
}
