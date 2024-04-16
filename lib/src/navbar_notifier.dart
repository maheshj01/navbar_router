import 'dart:async';

import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';

class NavbarNotifier extends ChangeNotifier {
  static final NavbarNotifier _singleton = NavbarNotifier._internal();

  factory NavbarNotifier() {
    return _singleton;
  }

  NavbarNotifier._internal();

  static int? _index;

  static int get currentIndex => _index ?? 0;

  static int? _length;

  static set length(int x) {
    _length = x;
  }

  static int get length => _length!;

  static bool _hideBottomNavBar = false;

  static List<int> _navbarStackHistory = [];

  static List<GlobalKey<NavigatorState>> _keys = [];

  /// Set to true will hide the badges when the tap on the navbar icon.
  static bool hideBadgeOnPageChanged = true;

  /// List of badges of the navbar
  static List<NavbarBadge> get badges => _badges;
  static List<NavbarBadge> _badges = [];

  /// Use to update a badge using its [index], e.g: update the number, text...
  ///
  /// If you want to hide badges on a specific index, use [makeBadgeVisible]
  ///
  static void setBadges(int index, NavbarBadge badge) {
    if (index < 0 || index >= length) return;
    badges[index] = badge;
    // TODO: wonder if this will cause performance issue
    _notifyIndexChangeListeners(index);
    _singleton.notify();
  }

  /// Use to set the visibility of a badge using its [index].
  static void makeBadgeVisible(int index, bool visible) {
    if (index < 0 || index >= length) return;
    badges[index].showBadge = visible;
  }

  /// Conveniently setup the badges if user choose to show them. Also the only place that init the badges.
  ///
  /// Will throw AssertionError if length of keys and given badgeList are not the same
  static void setKeys(List<GlobalKey<NavigatorState>> value,
      {List<NavbarBadge>? badgeList}) {
    _keys = value;
    if (badgeList != null) {
      _badges = badgeList;
    }
  }

  static final List<Function(int)> _indexChangeListeners = [];

  static List<GlobalKey<NavigatorState>> get keys => _keys;

  static set index(int x) {
    _index = x;
    if (hideBadgeOnPageChanged) badges[x].clearBadge();
    if (_navbarStackHistory.contains(x)) {
      _navbarStackHistory.remove(x);
    }
    _navbarStackHistory.add(x);
    _notifyIndexChangeListeners(x);
    _singleton.notify();
  }

  static List<int> get stackHistory => _navbarStackHistory;

  static bool get isNavbarHidden => _hideBottomNavBar;

  static set hideBottomNavBar(bool x) {
    _hideBottomNavBar = x;
    _singleton.notify();
  }

  static set setStackHistory(List<int> x) {
    if (x.isEmpty) return;
    _navbarStackHistory = x;
  }

  // pop routes from the nested navigator stack and not the main stack
  // this is done based on the currentIndex of the bottom navbar
  // if the backButton is pressed on the initial route the app will be terminated
  static FutureOr<bool> onBackButtonPressed(
      {BackButtonBehavior behavior =
          BackButtonBehavior.rememberHistory}) async {
    bool exitingApp = true;
    NavigatorState? currentState = _keys[_index!].currentState;
    if (currentState != null && currentState.canPop()) {
      currentState.pop();
      exitingApp = false;
    } else {
      if (behavior == BackButtonBehavior.rememberHistory) {
        if (_navbarStackHistory.length > 1) {
          _navbarStackHistory.removeLast();
          _index = _navbarStackHistory.last;
          _singleton.notify();
          exitingApp = false;
        } else {
          return exitingApp;
        }
      } else {
        return exitingApp;
      }
    }
    return exitingApp;
  }

  /// pops the current route from a specific navigator stack
  /// by passing the index of the navigator stack to pop from.
  static void popRoute(int index) {
    NavigatorState? currentState;
    currentState = _keys[index].currentState;
    if (currentState != null && currentState.canPop()) {
      currentState.pop();
    }
  }

  /// Use this method to programmatically push a route to a specific navigator stack
  /// by passing the route name and the index of the navigator stack
  static void pushNamed(String route, int x) {
    NavigatorState? currentState;
    currentState = _keys[x].currentState;
    if (currentState != null) {
      currentState.pushNamed(route);
    }
  }

  /// pops all routes except first, if there are more than 1 route in each navigator stack
  static void popAllRoutes(int index) {
    NavigatorState? currentState;
    for (int i = 0; i < _keys.length; i++) {
      if (_index == i) {
        currentState = _keys[i].currentState;
      }
    }
    if (currentState != null && currentState.canPop()) {
      currentState.popUntil((route) => route.isFirst);
    }
  }

  // adds a listener to the list of listeners
  static void addIndexChangeListener(Function(int) listener) {
    _indexChangeListeners.add(listener);
  }

  // removes the last listener that was added
  static void removeLastListener() {
    if (_indexChangeListeners.isEmpty) return;
    _indexChangeListeners.removeLast();
  }

  // removes all listeners
  static void removeAllListeners() {
    if (_indexChangeListeners.isEmpty) return;
    _indexChangeListeners.clear();
  }

  static void _notifyIndexChangeListeners(int index) {
    if (_indexChangeListeners.isEmpty) return;
    for (Function(int) listener in _indexChangeListeners) {
      listener(index);
    }
  }

  void notify() {
    notifyListeners();
  }

  static void hideSnackBar(context) {
    if (ScaffoldMessenger.of(context).mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  static void _showMessage(BuildContext context, String message,
      {
      /// margin from bottom
      double? bottom,

      /// whether the snackbar should persist or not
      /// the persistence duration
      Duration duration = const Duration(seconds: 3),
      bool showCloseIcon = true,

      /// Action label is shown when both [onPressed] and [actionLabel] are not null
      String? actionLabel,
      void Function()? onPressed,
      void Function()? onClosed}) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            dismissDirection: DismissDirection.none,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            behavior: bottom != null
                ? SnackBarBehavior.floating
                : SnackBarBehavior.fixed,
            content: Text(
              message,
            ),
            duration: duration,
            margin: bottom != null ? EdgeInsets.only(bottom: bottom) : null,
            showCloseIcon: showCloseIcon,
            action: actionLabel == null || onPressed == null
                ? null
                : SnackBarAction(
                    label: actionLabel,
                    onPressed: onPressed,
                  ),
          ),
        )
        .closed
        .whenComplete(() {
      if (onClosed != null) {
        onClosed();
      }
    });
  }

  static void showSnackBar(BuildContext context, String message,
      {
      /// margin from bottom of navbar defaults to [kNavbarHeight]
      double? bottom,
      String? actionLabel,
      bool showCloseIcon = true,
      Duration duration = const Duration(seconds: 3),
      Function? onActionPressed,
      Function? onClosed}) {
    _showMessage(
      context,
      message,
      showCloseIcon: showCloseIcon,
      actionLabel: actionLabel,
      bottom: bottom ?? kNavbarHeight,
      duration: duration,
      onPressed: () {
        if (onActionPressed != null) {
          onActionPressed();
        }
      },
      onClosed: () {
        if (onClosed != null) {
          onClosed();
        }
      },
    );
  }

  static void clear() {
    _indexChangeListeners.clear();
    _navbarStackHistory.clear();
    _keys.clear();
    _index = null;
    _length = null;
    _badges.clear();
  }
}
