import 'package:flutter/material.dart';

const double kDragAreaTop = 50;
const double kDragAreaWidth = 500;
const double kOpacityWhenSwipeable = 0.5;
const double kDragAreaHeightFactor = 0.3;

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  final bool keepAlive;
  const KeepAliveWrapper({
    Key? key,
    required this.child,
    required this.keepAlive,
  }) : super(key: key);
  @override
  KeepAliveWrapperState createState() => KeepAliveWrapperState();
}

class KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  // Setting to true will force the tab to never be disposed. This could be dangerous.
  @override
  bool get wantKeepAlive => widget.keepAlive;
}
