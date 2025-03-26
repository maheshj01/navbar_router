// ignore_for_file: public_member_api_docs, sort_constructors_first, avoid_print
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:navbar_router/src/navbar_swipeable_utls.dart';

class Gesture {
  bool dragging = false;
  int pageViewIndex = 0;
  late PageController pageController;
  double Function() getPadding;
  BuildContext context;
  Gesture({
    required this.getPadding,
    required this.context,
  });

  /// Swipeable functions below
  // convert scrollable pixels to current index
  double getPageFromPixels(context) {
    return pageController.offset /
        (MediaQuery.of(context).size.width - getPadding());
  }

  double getPixelsFromPage(int page) {
    return (MediaQuery.of(context).size.width - getPadding()) * page;
  }

  // control when user can swipe to other page
  bool handleOverscroll(OverscrollNotification value) {
    if (!dragging) return false;
    print(value.overscroll);
    if (value.overscroll < 0 && pageController.offset + value.overscroll <= 0) {
      if (pageController.offset != 0) {
        pageController.jumpTo(0);
      }
      return true;
    }
    if (pageController.offset + value.overscroll >=
        pageController.position.maxScrollExtent) {
      if (pageController.offset != pageController.position.maxScrollExtent) {
        pageController.jumpTo(pageController.position.maxScrollExtent);
      }
      return true;
    }
    pageController.jumpTo(pageController.offset + value.overscroll);

    return true;
  }

  void onDragStart(details) {
    if (dragging) return;
    if (details.localPosition.dx <= kDragAreaWidth ||
        details.localPosition.dx >=
            MediaQuery.of(context).size.width - kDragAreaWidth) {
      dragging = true;
    }
  }

  double? onDragUpdate(DragUpdateDetails details) {
    // print(details.delta);
    double? newOffset;
    if (dragging) {
      var page = getPageFromPixels(context);
      // print(page);
      if ((page == 0 && details.delta.dx > 0.1) ||
          (page >= NavbarNotifier.length - 1 && details.delta.dx < -0.1)) {
        return null;
      }
      double newOffset = pageController.offset - details.delta.dx;
      print(newOffset / getPixelsFromPage(NavbarNotifier.currentIndex));

      // handle fade animation when swiping

      pageController.jumpTo(newOffset);
    }
    return newOffset;
  }

  int onDragEnd(details) {
    print(pageController.offset);
    // when user release the drag, we calculate which page they're on
    var page = getPageFromPixels(context);
    print(page);
    int value = page.round();
    if (value < 0) {
      pageController.animateTo(pageController.position.minScrollExtent,
          duration: Durations.long1, curve: Curves.ease);
    } else if (value >= NavbarNotifier.length) {
      pageController.animateTo(pageController.position.maxScrollExtent,
          duration: Durations.long1, curve: Curves.ease);
    } else {}

    dragging = false;
    return value;
  }
}
