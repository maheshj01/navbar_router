import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

/// A customized badge/dot class for NavbarRouter.
/// Based on [badges] package of flutter.
class NavbarBadge {
  /// Your badge content, can be number (as string) of text.
  /// Please choose either [badgeText] or [badgeContent].
  ///
  /// If **[badgeContent]** is not null, **[badgeText]** will be **ignored**.
  final String badgeText;

  /// Text style for badge
  final TextStyle? badgeTextStyle;

  /// Content inside badge. Please choose either [badgeText] or [badgeContent].
  ///
  /// If not null, **[badgeText]** will be **ignored**.
  final Widget? badgeContent;

  /// Allows you to hide or show entire badge.
  /// The default value is false.
  final bool showBadge;

  /// Duration of the badge animations when the [badgeContent] changes.
  /// The default value is Duration(milliseconds: 500).
  final Duration animationDuration;

  /// Background color of the badge.
  /// The default value is white.
  final Color? color;

  /// Text color of the badge.
  /// The default value is black.
  final Color? textColor;

  /// Contains all badge style properties.
  ///
  /// Allows to set the shape to this [badgeContent].
  /// The default value is [BadgeShape.circle].
  /// ```
  /// final BadgeShape shape;
  /// ```
  /// Allows to set border radius to this [badgeContent].
  /// The default value is [BorderRadius.zero].
  /// ```
  /// final BorderRadius borderRadius;
  /// ```
  /// Background color of the badge.
  /// If [gradient] is not null, this property will be ignored.
  /// ```
  /// final Color badgeColor;
  /// ```
  /// Allows to set border side to this [badgeContent].
  /// The default value is [BorderSide.none].
  /// ```
  /// final BorderSide borderSide;
  /// ```
  /// The size of the shadow below the badge.
  /// ```
  /// final double elevation;
  /// ```
  /// Background gradient color of the badge.
  /// Will be used over [badgeColor] if not null.
  /// ```
  /// final BadgeGradient? badgeGradient;
  /// ```
  /// Background gradient color of the border badge.
  /// Will be used over [borderSide.color] if not null.
  /// ```
  /// final BadgeGradient? borderGradient;
  /// ```
  /// Specifies padding/**size** for [badgeContent].
  /// The default value is EdgeInsets.all(5.0).
  /// ```
  /// final EdgeInsetsGeometry padding;
  /// ```
  final BadgeStyle badgeStyle;

  /// Contains all badge animation properties.
  ///
  /// True to animate badge on [badgeContent] change.
  /// False to disable animation.
  /// Default value is true.
  /// ```
  /// final bool toAnimate;
  /// ```
  /// Duration of the badge animations when the [badgeContent] changes.
  /// The default value is Duration(milliseconds: 500).
  /// ```
  /// final Duration animationDuration;
  /// ```
  /// Duration of the badge appearance and disappearance fade animations.
  /// Fade animation is created with [AnimatedOpacity].
  ///
  /// Some of the [BadgeAnimationType] cannot be used for appearance and disappearance animation.
  /// E.g. [BadgeAnimationType.scale] can be used, but [BadgeAnimationType.rotation] cannot be used.
  /// That is why we need fade animation and duration for it when it comes to appearance and disappearance
  /// of these "non-disappearing" animations.
  ///
  /// There is a thing: you need this duration to NOT be longer than [animationDuration]
  /// if you want to use the basic animation as appearance and disappearance animation.
  ///
  /// Set this to zero to skip the badge appearance and disappearance animations
  /// The default value is Duration(milliseconds: 200).
  /// ```
  /// final Duration disappearanceFadeAnimationDuration;
  /// ```
  /// Type of the animation for badge
  /// The default value is [BadgeAnimationType.slide].
  /// ```
  /// final BadgeAnimationType animationType;
  /// ```
  /// Make it true to have infinite animation
  /// False to have animation only when [badgeContent] is changed
  /// The default value is false
  /// ```
  /// final bool loopAnimation;
  /// ```
  /// Controls curve of the animation
  /// ```
  /// final Curve curve;
  /// ```
  /// Used only for [SizeTransition] animation
  /// The default value is Axis.horizontal
  /// ```
  /// final Axis? sizeTransitionAxis;
  /// ```
  /// Used only for [SizeTransition] animation
  /// The default value is 1.0
  /// ```
  /// final double? sizeTransitionAxisAlignment;
  /// ```
  /// Used only for [SlideTransition] animation
  /// The default value is
  /// ```
  /// SlideTween(
  ///   begin: const Offset(-0.5, 0.9),
  ///   end: const Offset(0.0, 0.0),
  /// );
  /// ```
  /// ```
  /// final SlideTween? slideTransitionPositionTween;
  /// ```
  /// Used only for changing color animation.
  /// The default value is [Curves.linear]
  /// ```
  /// final Curve colorChangeAnimationCurve;
  /// ```
  /// Used only for changing color animation.
  /// The default value is [Duration.zero], meaning that
  /// no animation will be applied to color change by default.
  /// ```
  /// final Duration colorChangeAnimationDuration;
  /// ```
  /// This one is interesting.
  /// Some animations use [AnimatedOpacity] to animate appearance and disappearance of the badge.
  /// E.x. how would you animate disappearance of [BadgeAnimationType.rotation]? We should use [AnimatedOpacity] for that.
  /// But sometimes you may need to disable this fade appearance/disappearance animation.
  /// You can do that by setting this to false.
  /// Using disappearanceFadeAnimationDuration: Duration.zero is not correct, this will remove the animation entirely
  /// ```
  /// final bool appearanceDisappearanceFadeAnimationEnabled;
  /// ```
  final BadgeAnimation? badgeAnimation;

  /// Allows to set custom position of badge according to [child].
  /// If [child] is null, it doesn't make sense to use it.
  final BadgePosition? position;

  /// Can make your [badgeContent] interactive.
  /// The default value is false.
  /// Make it true to make badge intercept all taps
  /// Make it false and all taps will be passed through the badge
  final bool ignorePointer;

  /// Allows to edit fit parameter to [Stack] widget.
  /// The default value is [StackFit.loose].
  final StackFit stackFit;

  /// Will be called when you tap on the badge
  /// Important: if the badge is outside of the child
  /// the additional padding will be applied to make the full badge clickable
  final Function()? onTap;

  final Key? key;

  /// Use padding of [badgeStyle] or fontSize of [badgeTextStyle] to change size of the badge/dot. 
  const NavbarBadge({
    this.key,
    this.badgeText = "",
    this.showBadge = false,
    this.animationDuration = const Duration(milliseconds: 500),
    this.color = Colors.white,
    this.textColor,
    this.badgeStyle = const BadgeStyle(),
    this.badgeAnimation = const BadgeAnimation.slide(),
    this.position,
    this.ignorePointer = false,
    this.stackFit = StackFit.loose,
    this.onTap,
    this.badgeContent,
    this.badgeTextStyle,
  });

  @override
  int get hashCode =>
      badgeText.hashCode ^
      showBadge.hashCode ^
      animationDuration.hashCode ^
      color.hashCode ^
      textColor.hashCode ^
      badgeStyle.hashCode ^
      badgeAnimation.hashCode ^
      position.hashCode ^
      ignorePointer.hashCode ^
      stackFit.hashCode ^
      onTap.hashCode ^
      badgeContent.hashCode ^
      badgeStyle.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NavbarBadge &&
            runtimeType == other.runtimeType &&
            badgeText == other.badgeText &&
            showBadge == other.showBadge &&
            animationDuration == other.animationDuration &&
            color == other.color &&
            textColor == other.textColor &&
            badgeStyle == other.badgeStyle &&
            badgeAnimation == other.badgeAnimation &&
            position == other.position &&
            ignorePointer == other.ignorePointer &&
            stackFit == other.stackFit &&
            onTap == other.onTap &&
            badgeContent == other.badgeContent &&
            badgeStyle == other.badgeStyle;
  }

  NavbarBadge copyWith({
    String? badgeText,
    TextStyle? badgeTextStyle,
    Widget? badgeContent,
    bool? showBadge,
    Duration? animationDuration,
    Color? color,
    Color? textColor,
    BadgeStyle? badgeStyle,
    BadgeAnimation? badgeAnimation,
    BadgePosition? position,
    bool? ignorePointer,
    StackFit? stackFit,
    Function()? onTap,
    Key? key,
  }) {
    return NavbarBadge(
      badgeText: badgeText ?? this.badgeText,
      badgeTextStyle: badgeTextStyle ?? this.badgeTextStyle,
      badgeContent: badgeContent ?? this.badgeContent,
      showBadge: showBadge ?? this.showBadge,
      animationDuration: animationDuration ?? this.animationDuration,
      color: color ?? this.color,
      textColor: textColor ?? this.textColor,
      badgeStyle: badgeStyle ?? this.badgeStyle,
      badgeAnimation: badgeAnimation ?? this.badgeAnimation,
      position: position ?? this.position,
      ignorePointer: ignorePointer ?? this.ignorePointer,
      stackFit: stackFit ?? this.stackFit,
      onTap: onTap ?? this.onTap,
      key: key ?? this.key,
    );
  }
}
