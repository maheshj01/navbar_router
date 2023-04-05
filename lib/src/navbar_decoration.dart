import 'package:flutter/material.dart';

class NavbarItem {
  const NavbarItem(this.iconData, this.text, {this.backgroundColor});

  /// IconData for the navbar item
  final IconData iconData;

  /// label for the navbar item
  final String text;

  /// background color for the navbar item when type is [NavbarType.shifting]
  final Color? backgroundColor;
}

/// Decoration class for the navbar [NavbarType.standard]
/// if you are using Navbartype.notched then use [NotchedDecoration] instead.
class NavbarDecoration {
  /// The type of the Navbar to be displayed
  /// [BottomNavigationBarType.fixed] or [BottomNavigationBarType.shifting]
  final BottomNavigationBarType? navbarType;

  /// The backgroundColor of the Navbar
  final Color? backgroundColor;

  /// Defines whether the Navbar is extended in Desktop mode
  /// defaults to false
  final bool isExtended;

  /// The color of the unselected item
  final Color? unselectedItemColor;

  /// The elevation shadown on the edges of bottomnavigationbar
  final double? elevation;

  /// The color of the unselected item icon
  final Color? unselectedIconColor;

  /// Whether or not to show the unselected label text
  final bool showUnselectedLabels;

  /// The color of the unselected label text
  final Color? unselectedLabelColor;

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

  final Color? indicatorColor;

  NavigationDestinationLabelBehavior? labelBehavior;

  NavbarDecoration({
    this.backgroundColor,
    this.elevation,
    this.enableFeedback,
    this.isExtended = false,
    this.indicatorColor,
    this.navbarType,
    this.labelBehavior,
    this.showSelectedLabels,
    this.showUnselectedLabels = true,
    this.selectedIconTheme,
    this.selectedLabelTextStyle,
    this.unselectedIconTheme,
    this.unselectedLabelTextStyle,
    this.unselectedIconColor,
    this.unselectedItemColor,
    this.unselectedLabelColor,
  });

  // copyWith
  NavbarDecoration copyWith({
    BottomNavigationBarType? navbarType,
    Color? backgroundColor,
    bool? isExtended,
    Color? unselectedItemColor,
    double? elevation,
    Color? unselectedIconColor,
    bool? showUnselectedLabels,
    Color? unselectedLabelColor,
    bool? showSelectedLabels,
    bool? enableFeedback,
    Color? indicatorColor,
    NavigationDestinationLabelBehavior? labelBehavior,
    TextStyle? selectedLabelTextStyle,
    TextStyle? unselectedLabelTextStyle,
    IconThemeData? selectedIconTheme,
    IconThemeData? unselectedIconTheme,
  }) =>
      NavbarDecoration(
        navbarType: navbarType ?? this.navbarType,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        isExtended: isExtended ?? this.isExtended,
        unselectedItemColor: unselectedItemColor ?? this.unselectedItemColor,
        elevation: elevation ?? this.elevation,
        unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
        showUnselectedLabels: showUnselectedLabels ?? this.showUnselectedLabels,
        unselectedLabelColor: unselectedLabelColor ?? this.unselectedLabelColor,
        showSelectedLabels: showSelectedLabels ?? this.showSelectedLabels,
        enableFeedback: enableFeedback ?? this.enableFeedback,
        indicatorColor: indicatorColor ?? this.indicatorColor,
        labelBehavior: labelBehavior ?? this.labelBehavior,
        selectedLabelTextStyle:
            selectedLabelTextStyle ?? this.selectedLabelTextStyle,
        unselectedLabelTextStyle:
            unselectedLabelTextStyle ?? this.unselectedLabelTextStyle,
        selectedIconTheme: selectedIconTheme ?? this.selectedIconTheme,
        unselectedIconTheme: unselectedIconTheme ?? this.unselectedIconTheme,
      );
}

class NotchedDecoration extends NavbarDecoration {
  NotchedDecoration({
    Color? backgroundColor,
    double? elevation,
    bool? showUnselectedLabels = true,
    TextStyle? unselectedLabelTextStyle,
    Color? unselectedIconColor,
    Color? unselectedItemColor,
    Color? unselectedLabelColor,
    IconThemeData? selectedIconTheme,
  }) : super(
          backgroundColor: backgroundColor,
          elevation: elevation,
          unselectedItemColor: unselectedItemColor,
          unselectedIconColor: unselectedIconColor,
          showUnselectedLabels: showUnselectedLabels!,
          unselectedLabelColor: unselectedLabelColor,
          unselectedLabelTextStyle: unselectedLabelTextStyle,
          selectedIconTheme: selectedIconTheme,
        );

  factory NotchedDecoration.fromNavbarDecoration(
          NavbarDecoration navbarDecoration) =>
      NotchedDecoration(
        backgroundColor: navbarDecoration.backgroundColor,
        elevation: navbarDecoration.elevation,
        unselectedItemColor: navbarDecoration.unselectedItemColor,
        unselectedIconColor: navbarDecoration.unselectedIconColor,
        showUnselectedLabels: navbarDecoration.showUnselectedLabels,
        unselectedLabelColor: navbarDecoration.unselectedLabelColor,
        unselectedLabelTextStyle: navbarDecoration.unselectedLabelTextStyle,
        selectedIconTheme: navbarDecoration.selectedIconTheme,
      );

  /// to navb bar decoration

  NavbarDecoration toNavbarDecoration() => NavbarDecoration(
        backgroundColor: backgroundColor,
        elevation: elevation,
        unselectedItemColor: unselectedItemColor,
        unselectedIconColor: unselectedIconColor,
        showUnselectedLabels: showUnselectedLabels,
        unselectedLabelColor: unselectedLabelColor,
        unselectedLabelTextStyle: unselectedLabelTextStyle,
      );
}

class M3NavbarDecoration extends NavbarDecoration {
  M3NavbarDecoration({
    /// The backgroundColor of the Navbar
    Color? backgroundColor,

    /// Defines whether to show/hide labels
    NavigationDestinationLabelBehavior labelBehavior =
        NavigationDestinationLabelBehavior.alwaysShow,

    /// Color for the indicator shown around the seleccted item
    Color? indicatorColor,

    /// Textstyle of the labels
    TextStyle? labelTextStyle,
    double? elevation,

    /// iconTheme for the icons
    IconThemeData? iconTheme,
  }) : super(
          backgroundColor: backgroundColor,
          elevation: elevation,
          indicatorColor: indicatorColor,
          labelBehavior: labelBehavior,
          selectedLabelTextStyle: labelTextStyle,
          selectedIconTheme: iconTheme,
        );

  factory M3NavbarDecoration.fromNavbarDecoration(
          NavbarDecoration navbarDecoration) =>
      M3NavbarDecoration(
          backgroundColor: navbarDecoration.backgroundColor,
          elevation: navbarDecoration.elevation,
          labelTextStyle: navbarDecoration.selectedLabelTextStyle,
          iconTheme: navbarDecoration.selectedIconTheme,
          indicatorColor: navbarDecoration.selectedIconTheme?.color,
          labelBehavior: navbarDecoration.labelBehavior ??
              NavigationDestinationLabelBehavior.alwaysShow);

  /// to navb bar decoration

  NavbarDecoration toNavbarDecoration() => NavbarDecoration(
        backgroundColor: backgroundColor,
        elevation: elevation,
        unselectedItemColor: unselectedItemColor,
        unselectedIconColor: unselectedIconColor,
        showUnselectedLabels: showUnselectedLabels,
        unselectedLabelColor: unselectedLabelColor,
        unselectedLabelTextStyle: unselectedLabelTextStyle,
        labelBehavior: labelBehavior,
      );
}
