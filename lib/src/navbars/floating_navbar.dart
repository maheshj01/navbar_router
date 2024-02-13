import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

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

  Widget _unselectedIcon(int i) {
    return Icon(
      widget.items[i].iconData,
      size: 26,
      color: _selectedIndex == i
          ? widget.decoration.selectedIconColor
          : widget.decoration.unselectedIconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Theme(
        data: Theme.of(context).copyWith(
            navigationBarTheme: NavigationBarThemeData(
          backgroundColor: widget.decoration.backgroundColor ??
              Theme.of(context).colorScheme.surface,
          elevation: widget.elevation,
          labelTextStyle: MaterialStateProperty.all(
              widget.decoration.selectedLabelTextStyle),
          indicatorShape: widget.decoration.indicatorShape ??
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          iconTheme:
              MaterialStateProperty.all(widget.decoration.selectedIconTheme),
          labelBehavior: widget.decoration.showSelectedLabels!
              ? NavigationDestinationLabelBehavior.onlyShowSelected
              : NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: widget.decoration.indicatorColor,
          height: widget.height,
        )),
        child: Container(
          height: widget.navbarHeight,
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
                        height: widget.navbarHeight,
                        child: widget.items[i].child ??
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _selectedIndex == i
                                    ? widget.items[i].selectedIcon ??
                                        _unselectedIcon(i)
                                    : _unselectedIcon(i),
                                if (widget.decoration.showSelectedLabels! &&
                                    widget.index == i)
                                  Text(
                                    widget.items[i].text,
                                    style: widget
                                        .decoration.selectedLabelTextStyle,
                                  )
                              ],
                            ),
                      )),
                ))
            ],
          ),
        ));
  }
}
