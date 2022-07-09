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
                    elevation: widget.decoration!.elevation,
                    onDestinationSelected: (x) {
                      widget.onItemTapped(x);
                    },
                    selectedLabelTextStyle:
                        widget.decoration!.selectedLabelTextStyle,
                    unselectedLabelTextStyle:
                        widget.decoration!.unselectedLabelTextStyle,
                    unselectedIconTheme: widget.decoration!.unselectedIconTheme,
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
                : BottomNavigationBar(
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
                    elevation: widget.decoration?.elevation,
                    iconSize: Theme.of(context).iconTheme.size ?? 24.0,
                    unselectedItemColor: widget.decoration?.unselectedItemColor,
                    selectedItemColor:
                        widget.decoration!.selectedLabelTextStyle?.color,
                    unselectedLabelStyle:
                        widget.decoration!.unselectedLabelTextStyle,
                    selectedLabelStyle:
                        widget.decoration?.selectedLabelTextStyle,
                    selectedIconTheme: widget.decoration!.selectedIconTheme,
                    unselectedIconTheme: widget.decoration?.unselectedIconTheme,
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
        });
  }
}
