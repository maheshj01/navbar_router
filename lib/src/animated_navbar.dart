part of 'navbar_router.dart';

class NavbarItem {
  const NavbarItem(this.iconData, this.text, {this.backgroundColor});

  /// IconData for the navbar item
  final IconData iconData;

  /// label for the navbar item
  final String text;

  /// background color for the navbar item whnen type is [NavbarType.shifting]
  final Color? backgroundColor;
}

class NavbarDecoration {
  /// The type of the Navbar to be displayed
  /// [BottomNavigationBarType.fixed] or [BottomNavigationBarType.shifting]
  final BottomNavigationBarType? navbarType;

  /// The backgroundColor of the Navbar
  final Color? backgroundColor;

  /// Defines whether the Navbar is extended in Desktop mode
  /// defaultst to false
  final bool isExtended;

  /// The color of the unselected item
  final Color? unselectedItemColor;

  /// The elevation shadown on the edges of bottomnavigationbar
  final double? elevation;

  /// The color of the unselected item icon
  final Color? unselectedIconColor;

  /// Whether or not to show the unselected label text
  final bool? showUnselectedLabels;

  /// The color of the unselected label text
  final Color? unselectedLabelColor;

  /// The color of the label text
  final Color? selectedLabelColor;

  /// whether or not to show the selected label text
  final bool? showSelectedLabels;

  /// haptic feedbakc when the item is selected
  final bool? enableFeedback;

  /// the text style of the selected label
  final TextStyle? selectedLabelTextStyle;

  /// the text style of the unselected labels
  final TextStyle? unselectedLabelTextStyle;

  /// iconTheme for the selected icon
  final IconThemeData? selectedIconTheme;

  /// iconTheme for the unselected icon
  final IconThemeData? unselectedIconTheme;

  NavbarDecoration({
    this.backgroundColor,
    this.elevation,
    this.enableFeedback,
    this.isExtended = false,
    this.navbarType,
    this.showSelectedLabels,
    this.showUnselectedLabels = true,
    this.selectedIconTheme,
    this.selectedLabelColor,
    this.selectedLabelTextStyle,
    this.unselectedIconTheme,
    this.unselectedLabelTextStyle,
    this.unselectedIconColor,
    this.unselectedItemColor,
    this.unselectedLabelColor,
  });
}

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
    NavbarBase _buildNavBar() {
      switch (widget.navbarType) {
        case NavbarType.standard:
          return StandardNavbar(
            navBarDecoration: widget.decoration!,
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            navBarElevation: widget.decoration!.elevation,
          );
        case NavbarType.notched:
          return NotchedNavBar(
            navBarDecoration: widget.decoration!,
            items: widget.menuItems,
            onTap: widget.onItemTapped,
            color: widget.decoration!.backgroundColor,
            navBarElevation: widget.decoration!.elevation,
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
      required this.items})
      : super(key: key);

  final List<NavbarItem> items;
  final Function(int) onTap;
  final NavbarDecoration navBarDecoration;
  final double? navBarElevation;

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
      required this.navBarDecoration,
      required this.color,
      required this.navBarElevation,
      required this.onTap,
      required this.items})
      : super(key: key);

  final List<NavbarItem> items;
  final Function(int) onTap;
  final NavbarDecoration navBarDecoration;
  final Color? color;
  final double? navBarElevation;

  @override
  Color? get backgroundColor => color;

  @override
  NotchedNavBarState createState() => NotchedNavBarState();

  @override
  NavbarDecoration get decoration => navBarDecoration;

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
      duration: const Duration(milliseconds: 300),
    );
    _controller!.forward();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  late AnimationController? _controller;
  late Animation<double> animation = CurvedAnimation(
    parent: _controller!,
    curve: Curves.bounceInOut,
  );
  void _startAnimation() async {
    _controller!.reset();
    _controller!.forward();
  }

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final selectedWidget = AnimatedBuilder(
        animation: _controller!,
        builder: (context, snapshot) {
          return Transform.scale(
            scale: animation.value,
            child: FloatingActionButton(
                onPressed: () {
                  widget.onItemTapped!(NavbarNotifier.currentIndex);
                },
                child: Icon(
                    widget.menuItems[NavbarNotifier.currentIndex].iconData)),
          );
        });

    return Stack(
      children: [
        AnimatedBuilder(
            animation: _controller!,
            builder: (context, snapshot) {
              return ClipPath(
                clipper: NotchedClipper(
                    index: NavbarNotifier.currentIndex,
                    animation: animation.value),
                child: Container(
                  color: widget.decoration.backgroundColor,
                  height: kBottomNavigationBarHeight * 1.6,
                  alignment: Alignment.center,
                ),
              );
            }),
        Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < widget.menuItems.length; i++)
                Expanded(
                    child: _selectedIndex == i
                        ? selectedWidget
                        : IconButton(
                            icon: MenuTile(item: widget.menuItems[i]),
                            onPressed: () {
                              _selectedIndex = i;
                              widget.onItemTapped!(i);
                              _startAnimation();
                            },
                          ))
            ]),
      ],
    );
  }
}

class MenuTile extends StatelessWidget {
  final NavbarItem item;

  const MenuTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [Icon(item.iconData), Flexible(child: Text(item.text))],
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

    // work around for calculating the center of notched navbar
    // for different number of items
    // 0 -> 0.16
    // 1 -> 0.5
    // 2 -> 0.84
    // 2 items width * (0.1 + (0.2 * index));
    // 3 items width * (0.16 + (0.34 * index));
    // 4 items width * (0.12 + (0.25 * index));
    // 5 items width * (0.1 + (0.2 * index));
    // in general width * (0.12 + (0.25 * index));

    double centerX = width * (0.1 + (0.2 * index));

    switch (items) {
      case 3:
        centerX = width * (0.16 + (0.34 * index));
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

    double centerY = height * 0.5;

    Offset point1 = Offset(centerX - curveRadius, 0);
    path.lineTo(point1.dx, point1.dy);
    point1 = Offset(centerX - curveRadius * 2, elevationFromEdge);
    Offset point2 = Offset(point1.dx + 20, 0);
    Offset point3 = Offset(centerX - curveRadius, 0);
    path.cubicTo(
        point1.dx, point1.dy, point2.dx, point2.dy, point3.dx, point3.dy);

    point1 = Offset(centerX - (curveRadius / 4), 0);
    point2 = Offset(centerX - (curveRadius / 1.2), curveRadius);
    point3 = Offset(centerX, curveRadius);

    path.cubicTo(
        point1.dx, point1.dy, point2.dx, point2.dy, point3.dx, point3.dy);

    point1 = Offset(centerX + (curveRadius / 1.2), curveRadius);
    point2 = Offset(centerX + (curveRadius / 4), 0);
    point3 = Offset(centerX + curveRadius, 0);
    path.cubicTo(
        point1.dx, point1.dy, point2.dx, point2.dy, point3.dx, point3.dy);
    // path.quadraticBezierTo(point1.dx, point1.dy, point2.dx, point2.dy);
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
