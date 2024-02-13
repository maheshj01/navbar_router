import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

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
          navigationBarTheme: NavigationBarThemeData(
        backgroundColor: widget.decoration.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        elevation: widget.elevation,
        labelTextStyle:
            MaterialStateProperty.all(widget.decoration.selectedLabelTextStyle),
        indicatorShape: widget.decoration.indicatorShape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        iconTheme:
            MaterialStateProperty.all(widget.decoration.selectedIconTheme),
        labelBehavior: widget.decoration.showUnselectedLabels
            ? NavigationDestinationLabelBehavior.alwaysShow
            : NavigationDestinationLabelBehavior.onlyShowSelected,
        indicatorColor: widget.decoration.indicatorColor,
        height: widget.height,
      )),
      child: MediaQuery(
        data: MediaQuery.of(context).removePadding(removeTop: true),
        child: NavigationBar(
            height: widget.height,
            backgroundColor: widget.decoration.backgroundColor ??
                Theme.of(context).colorScheme.surface,
            animationDuration: const Duration(milliseconds: 300),
            elevation: widget.elevation,
            indicatorColor: widget.decoration.indicatorColor,
            indicatorShape: widget.decoration.indicatorShape,
            labelBehavior: widget.labelBehavior,
            destinations: widget.items.map((e) {
              return NavigationDestination(
                tooltip: e.text,
                icon: Icon(e.iconData),
                label: e.text,
                selectedIcon: e.selectedIcon ?? Icon(e.iconData),
              );
            }).toList(),
            selectedIndex: NavbarNotifier.currentIndex,
            onDestinationSelected: (int index) => widget.onItemTapped!(index)),
      ),
    );
  }
}
