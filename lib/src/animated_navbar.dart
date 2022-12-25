part of 'navbar_router.dart';

enum NavbarType { standard, notched }

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
    final _defaultDecoration = NavbarDecoration(
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      elevation: 8,
      showUnselectedLabels: true,
      unselectedIconColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      unselectedLabelColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      unselectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      unselectedLabelTextStyle:
          Theme.of(context).bottomNavigationBarTheme.unselectedLabelStyle ??
              const TextStyle(color: Colors.black),
      unselectedIconTheme: Theme.of(context).iconTheme,
      selectedIconTheme: Theme.of(context).iconTheme,
      selectedLabelTextStyle:
          Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle,
      enableFeedback: true,
      isExtended: true,
      navbarType: BottomNavigationBarType.fixed,
      selectedLabelColor:
          Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      showSelectedLabels: true,
    );

    NavbarBase _buildNavBar() {
      switch (widget.navbarType) {
        case NavbarType.standard:
          return StandardNavbar(
            navBarDecoration: widget.decoration ?? _defaultDecoration,
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            navBarElevation: widget.decoration!.elevation,
          );
        case NavbarType.notched:
          final _decoration = _defaultDecoration.copyWith(
              backgroundColor: widget.decoration!.backgroundColor ??
                  Theme.of(context).primaryColor,
              elevation: widget.decoration!.elevation,
              showUnselectedLabels: widget.decoration!.showUnselectedLabels,
              unselectedIconColor: widget.decoration!.unselectedIconColor,
              unselectedLabelColor: widget.decoration!.unselectedLabelColor,
              unselectedItemColor: widget.decoration!.unselectedItemColor,
              unselectedLabelTextStyle:
                  widget.decoration!.unselectedLabelTextStyle,
              unselectedIconTheme: widget.decoration!.unselectedIconTheme,
              selectedIconTheme: widget.decoration!.selectedIconTheme ??
                  const IconThemeData(color: Colors.white, size: 24),
              enableFeedback: widget.decoration!.enableFeedback,
              showSelectedLabels: false);
          return NotchedNavBar(
            notchDecoration:
                NotchedDecoration.fromNavbarDecoration(_decoration),
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            color: widget.decoration!.backgroundColor,
            navBarElevation: widget.decoration!.elevation,
            index: NavbarNotifier.currentIndex,
          );
        default:
          return StandardNavbar(
            navBarDecoration: widget.decoration!,
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            navBarElevation: widget.decoration!.elevation,
          );
      }
    }

    return AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
              offset: widget.isDesktop
                  ? Offset(-animation.value, 0)
                  : Offset(0, animation.value),
              child: widget.isDesktop
                  ? NavigationRail(
                      elevation: widget.decoration!.elevation,
                      onDestinationSelected: (x) {
                        widget.onItemTapped(x);
                      },
                      selectedLabelTextStyle:
                          widget.decoration!.selectedLabelTextStyle,
                      unselectedLabelTextStyle:
                          widget.decoration!.unselectedLabelTextStyle,
                      unselectedIconTheme:
                          widget.decoration!.unselectedIconTheme,
                      selectedIconTheme: widget.decoration!.selectedIconTheme,
                      extended: widget.decoration!.isExtended,
                      backgroundColor: widget.decoration?.backgroundColor,
                      destinations: widget.menuItems.map((NavbarItem menuItem) {
                        return NavigationRailDestination(
                          icon: Icon(menuItem.iconData),
                          label: Text(menuItem.text),
                        );
                      }).toList(),
                      selectedIndex: NavbarNotifier.currentIndex)
                  : _buildNavBar());
        });
  }
}

abstract class NavbarBase extends StatefulWidget {
  const NavbarBase({Key? key}) : super(key: key);
  NavbarDecoration get decoration;

  double? get elevation;

  Function(int)? get onItemTapped;

  List<NavbarItem> get menuItems;
}

class StandardNavbar extends NavbarBase {
  const StandardNavbar(
      {Key? key,
      required this.navBarDecoration,
      required this.navBarElevation,
      required this.onTap,
      this.index = 0,
      required this.items})
      : super(key: key);

  final List<NavbarItem> items;
  final Function(int) onTap;
  final NavbarDecoration navBarDecoration;
  final double? navBarElevation;
  final int index;

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
}

class StandardNavbarState extends State<StandardNavbar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      selectedItemColor: widget.decoration.selectedLabelColor,
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

  @override
  Widget build(BuildContext context) {
    final selectedWidget = AnimatedBuilder(
        animation: _controller!,
        builder: (context, snapshot) {
          return Transform.translate(
            offset: Offset(0, -iconAnimation.value),
            // scale: animation.value,
            child: Opacity(
              opacity: opacityAnimation.value,
              child: SizedBox(
                  height: 60.0,
                  width: 60.0,
                  child: FittedBox(
                    child: FloatingActionButton(
                        backgroundColor: widget.decoration.backgroundColor,
                        onPressed: () {
                          widget.onItemTapped!(NavbarNotifier.currentIndex);
                        },
                        child: Icon(
                            widget.menuItems[NavbarNotifier.currentIndex]
                                .iconData,
                            color: widget.decoration.selectedIconTheme?.color)),
                  )),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.decoration.backgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    height: kBottomNavigationBarHeight * 1.6,
                    alignment: Alignment.center,
                  ),
                );
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
    double curveRadius = 60.0 * animation;
    const elevationFromEdge = 5.0;

    path.moveTo(0, elevationFromEdge);
    int items = NavbarNotifier.length;
    // path.lineTo(size.width / 2, 0);
    // TODO: fix the center of the notched navbar logic
    // to a general formula

    // work around for calculating the center of notched navbar
    // for different number of items
    // 0 -> 0.16
    // 1 -> 0.5
    // 2 -> 0.84
    // 3 items width * (0.16 + (0.34 * index));
    // 4 items width * (0.12 + (0.25 * index));
    // 5 items width * (0.1 + (0.2 * index));
    // in general width * (0.12 + (0.25 * index));

    double centerX = width * (0.1 + (0.2 * index) * animation);

    switch (items) {
      case 3:
        centerX = width * (0.15 + (0.34 * index));
        break;
      case 4:
        centerX = width * (0.12 + (0.25 * index));
        break;
      case 5:
        centerX = width * (0.1 + (0.2 * index));
        break;
      default:
        centerX = width * (0.1 + (0.2 * index));
    }
    double depth = curveRadius * 1;
    Offset point1 = Offset(centerX - curveRadius, 0);
    path.lineTo(point1.dx, point1.dy);
    point1 = Offset(centerX - curveRadius * 2, elevationFromEdge);
    Offset point2 = Offset(point1.dx + 20, 0);
    Offset point3 = Offset(centerX - curveRadius, 0);
    path.cubicTo(
        point1.dx, point1.dy, point2.dx, point2.dy, point3.dx, point3.dy);

    point1 = Offset(centerX - (curveRadius / 4), 0);
    point2 = Offset(centerX - (curveRadius / 1.2), depth);
    point3 = Offset(centerX, depth);

    path.cubicTo(
        point1.dx, point1.dy, point2.dx, point2.dy, point3.dx, point3.dy);

    point1 = Offset(centerX + (curveRadius), depth);
    point2 = Offset(centerX + (curveRadius / 3), 0);
    point3 = Offset(centerX + curveRadius, 0);
    path.cubicTo(
        point1.dx, point1.dy, point2.dx, point2.dy, point3.dx, point3.dy);

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
