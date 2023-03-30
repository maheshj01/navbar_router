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
    Color? selectedLabelColor,
    bool? showSelectedLabels,
    bool? enableFeedback,
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
        selectedLabelColor: selectedLabelColor ?? this.selectedLabelColor,
        showSelectedLabels: showSelectedLabels ?? this.showSelectedLabels,
        enableFeedback: enableFeedback ?? this.enableFeedback,
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
