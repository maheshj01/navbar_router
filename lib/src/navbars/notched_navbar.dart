import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

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
        child: widget.menuItems[NavbarNotifier.currentIndex].selectedIcon ??
            Icon(
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
