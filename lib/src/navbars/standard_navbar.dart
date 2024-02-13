import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

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
    _selectedIndex = widget.index;
  }

  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final items = widget.menuItems;
    return BottomNavigationBar(
        type: widget.decoration.navbarType,
        currentIndex: NavbarNotifier.currentIndex,
        onTap: (x) {
          _selectedIndex = x;
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
        items: [
          for (int index = 0; index < items.length; index++)
            BottomNavigationBarItem(
              backgroundColor: items[index].backgroundColor,
              icon: _selectedIndex == index
                  ? items[index].selectedIcon ??
                      Icon(
                        items[index].iconData,
                      )
                  : Icon(
                      items[index].iconData,
                    ),
              label: items[index].text,
            )
        ]);
  }
}
