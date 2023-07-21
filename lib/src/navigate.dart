import 'package:flutter/material.dart';

enum TransitionType {
  // slide
  /// left to right
  ltr,

  /// right to left
  rtl,

  /// top to bottom
  ttb,

  /// bottom to top
  btt,

  /// bottom left
  bl,

  /// bottom right
  br,

  /// top left
  tl,

  /// top right
  tr,

  /// scale
  scale,

  /// fade
  fade,

  /// fade scale
  fadeScale,

  /// circular reveal
  reveal
}

class Navigate<T> {
  /// Replace the top widget with another widget
  static Future<T?> pushReplace<T>(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,

      /// Offset for TransitionType.reveal
      /// default is center of screen
      Offset? offset,
      TransitionType transitionType = TransitionType.scale,
      Duration transitionDuration = const Duration(milliseconds: 300)}) async {
    final T value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushReplacement(NavigateRoute(widget,
            type: transitionType,
            offset: offset,
            animationDuration: transitionDuration));
    return value;
  }

  static Future<T?> pushReplaceNamed<T>(BuildContext context, String path,
      {bool isDialog = false,
      Object? arguments,
      bool isRootNavigator = false}) async {
    final T? value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushReplacementNamed(path, arguments: arguments);
    return value;
  }

  static Future<T?> push<T>(BuildContext context, Widget widget,
      {bool isDialog = false,
      bool isRootNavigator = true,

      /// Offset for TransitionType.reveal
      /// default is center of screen
      Offset? offset,
      TransitionType transitionType = TransitionType.scale,
      Duration transitionDuration = const Duration(milliseconds: 300)}) async {
    final T value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .push(NavigateRoute(widget,
            type: transitionType,
            offset: offset,
            animationDuration: transitionDuration));
    return value;
  }

  static Future<void> pushNamed(BuildContext context, String path,
      {bool isDialog = false,
      Object? arguments,
      TransitionType transitionType = TransitionType.scale,
      bool isRootNavigator = false}) async {
    await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushNamed(path, arguments: arguments);
  }

// pop all Routes except first
  static void popToFirst(BuildContext context, {bool isRootNavigator = true}) =>
      Navigator.of(context, rootNavigator: isRootNavigator)
          .popUntil((route) => route.isFirst);

  static Future<void> popView<T>(BuildContext context,
          {T? value, bool isRootNavigator = true}) async =>
      Navigator.of(context, rootNavigator: isRootNavigator).pop(value);

  static Future<void> pushAndPopAll(BuildContext context, Widget widget,
      {bool isRootNavigator = true,

      /// Offset for TransitionType.reveal
      /// default is center of screen
      Offset? offset,
      TransitionType transitionType = TransitionType.scale,
      Duration transitionDuration = const Duration(milliseconds: 300)}) async {
    final value = await Navigator.of(context, rootNavigator: isRootNavigator)
        .pushAndRemoveUntil(
            NavigateRoute(widget,
                type: transitionType,
                offset: offset,
                animationDuration: transitionDuration),
            (Route<dynamic> route) => false);
    return value;
  }
}

Offset getTransitionOffset(TransitionType type) {
  switch (type) {
    case TransitionType.ltr:
      return const Offset(-1.0, 0.0);
    case TransitionType.rtl:
      return const Offset(1.0, 0.0);
    case TransitionType.ttb:
      return const Offset(0.0, -1.0);
    case TransitionType.btt:
      return const Offset(0.0, 1.0);
    case TransitionType.bl:
      return const Offset(-1.0, 1.0);
    case TransitionType.br:
      return const Offset(1.0, 1.0);
    case TransitionType.tl:
      return const Offset(-1.0, -1.0);
    case TransitionType.tr:
      return const Offset(1.0, 1.0);
    case TransitionType.scale:
      return const Offset(0.6, 1.0);
    default:
      return const Offset(0.8, 0.0);
  }
}

class CircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  CircleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromCircle(radius: radius, center: center));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class NavigateRoute extends PageRouteBuilder {
  final Widget widget;
  final bool? rootNavigator;
  final TransitionType type;
  final Duration animationDuration;

  /// Offset for circular reveal transition
  final Offset? offset;

  NavigateRoute(this.widget,
      {this.rootNavigator,
      required this.type,
      this.offset,
      this.animationDuration = const Duration(milliseconds: 300)})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => widget,
          transitionDuration: animationDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (type == TransitionType.scale) {
              return ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 0.8, end: 1.0).chain(
                    CurveTween(curve: Curves.ease),
                  ),
                ),
                child: child,
              );
            } else if (type == TransitionType.fade) {
              return FadeTransition(
                opacity: animation.drive(
                  Tween(begin: 0.0, end: 1.0).chain(
                    CurveTween(curve: Curves.ease),
                  ),
                ),
                child: child,
              );
            } else if (type == TransitionType.fadeScale) {
              return ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 0.8, end: 1.0).chain(
                    CurveTween(curve: Curves.ease),
                  ),
                ),
                child: FadeTransition(
                  opacity: animation.drive(
                    Tween(begin: 0.2, end: 1.0).chain(
                      CurveTween(curve: Curves.ease),
                    ),
                  ),
                  child: child,
                ),
              );
            } else if (type == TransitionType.reveal) {
              final screenSize = MediaQuery.of(context).size;
              Offset center =
                  Offset(screenSize.width / 2, screenSize.height / 2);
              double beginRadius = 0.0;
              double endRadius = screenSize.height * 1.5;
              final tween = Tween(begin: beginRadius, end: endRadius);
              final radiusTweenAnimation = animation.drive(tween);
              return ClipPath(
                clipper: CircleClipper(
                    radius: radiusTweenAnimation.value,
                    center: offset ?? center),
                child: child,
              );
            }

            var begin = getTransitionOffset(type);
            var end = Offset.zero;
            var curve = Curves.ease;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          reverseTransitionDuration: const Duration(milliseconds: 100),
        );
}

// class PageRoutes {
//   static const double kDefaultDuration = 0.5;
//   static Route<T> fadeThrough<T>(Widget page,
//       [double duration = kDefaultDuration]) {
//     return PageRouteBuilder<T>(
//       transitionDuration: Duration(milliseconds: (duration * 1000).round()),
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeThroughTransition(
//             animation: animation,
//             secondaryAnimation: secondaryAnimation,
//             child: child);
//       },
//     );
//   }

//   static Route<T> fadeScale<T>(Widget page,
//       [double duration = kDefaultDuration]) {
//     return PageRouteBuilder<T>(
//       transitionDuration: Duration(milliseconds: (duration * 1000).round()),
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeScaleTransition(animation: animation, child: child);
//       },
//     );
//   }

//   static Route<T> sharedAxis<T>(Widget page,
//       [SharedAxisTransitionType type = SharedAxisTransitionType.scaled,
//       double duration = kDefaultDuration]) {
//     return PageRouteBuilder<T>(
//       transitionDuration: Duration(milliseconds: (duration * 1000).round()),
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         return SharedAxisTransition(
//           animation: animation,
//           secondaryAnimation: secondaryAnimation,
//           transitionType: type,
//           child: child,
//         );
//       },
//     );
//   }
// }
