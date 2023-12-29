import 'package:navbar_router/navbar_router.dart';

bool areDestinationRoutersEqual(
    List<DestinationRouter> list1, List<DestinationRouter> list2) {
  if (list1.length != list2.length) {
    return false;
  }

  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }

  return true;
}
