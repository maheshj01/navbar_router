## **navbar_router 0.1.1**

 <a href="https://pub.dev/packages/navbar_router"><img src="https://img.shields.io/pub/v/navbar_router.svg" alt="Pub"></a>

This is the ultimate BottomNavigionBar, which will allow you to focus on the logic of your app. This widget handles the boilerplate code required to handle the below features with minimal code and hassle. All you need to do is specify the navbar menu items, routes and destinations and the rest will be taken care by the navbar_router.

## **Features**

- Ability to push routes in the nested or root navigator
- Notifies onBackButtonPress to handle app exits like a pro
- Ability to hide or show bottomNavigationBar in a single line of code
- maintain state across bottom navbar tabs
- Tapping the same navbar button pops to base route of nested navigator (same as instagram)
- Switch the Navbar destination with animation


_Heres a [sample app](example/lib/main.dart) built using this package to see how it works._

_video demo of the sample app_


https://user-images.githubusercontent.com/31410839/170913498-f1094090-bd80-43e6-ba09-7aa3dea029ba.mp4


This package will help you save atleast 50% lines of code in half the time required to implement the above features. Heres the same [sample app](https://dartpad.dev/?id=894922ccb67f5fdc4ffb652e41916fa2) without the package which requires around 800 lines of code.

## **Usage**

Add to pubspec.yaml

```yaml
  navbar_router: ^0.1.1
```

*Example*


```dart

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  List<IconData> icons = [Icons.home, Icons.shopping_basket, Icons.person];

  final Map<int, Map<String, Widget>> _routes = const {
    0: {
      '/': HomeFeeds(),
      FeedDetail.route: FeedDetail(),
    },
    1: {
      '/': ProductList(),
      ProductDetail.route: ProductDetail(),
    },
    2: {
      '/': UserProfile(),
      ProfileEdit.route: ProfileEdit(),
    },
  };

  @override
  Widget build(BuildContext context) {
    return NavbarRouter(
      errorBuilder: (context) {
        return const Center(child: Text('Error 404'));
      },
      onBackButtonPressed: (isExiting) {
        return isExiting;
      },
      destinationAnimationCurve: Curves.fastOutSlowIn,
      destinationAnimationDuration: 600,
      decoration:
          NavbarDecoration(navbarType: BottomNavigationBarType.shifting),
      destinations: [
        for (int i = 0; i < icons.length; i++)
          DestinationRouter(
            navbarItem:
                NavbarItem(icons[i], 'Home', backgroundColor: colors[i]),
            destinations: [
              for (int j = 0; j < _routes[i]!.keys.length; j++)
                Destination(
                  route: _routes[i]!.keys.elementAt(j),
                  widget: _routes[i]!.values.elementAt(j),
                ),
            ],
            initialRoute: _routes[i]!.keys.first,
          ),
      ],
    );
  }
}
```

## **Docs**

  ***destinations***: A List of `DestinationRouter` to show when the user taps the [NavbarItem].
  Each DestinationRouter specifies a List of Destinations, initialRoute, and the navbarItem corresponding to that destination.

  *errorBuilder*: A WidgetBuilder to show the user when the user tried to navigate to a route that does not exist in the [destinations].

  ***decoration*** : The decoraton for Navbar has all the properties you would expect in a [BottomNavigationBar] to adjust the style of the Navbar.

  *onBackButtonPressed*: A Function which defines whether it is the root Navigator or not
   if the method returns true then the Navigator is at the base of the navigator stack

   ***destinationAnimationCurve***: Curve for the destination animation when the user taps a navbar item. Defaults to `Curves.fastOutSlowIn`.

   ***destinationAnimationDuration***: The duration in milliseconds of the animation of the destination. Defaults to 700ms.

   ***shouldPopToBaseRoute***: A boolean which decides, whether the navbar should pop to base route( pop all except first) when the current navbar is tapped while the route is deeply nested. This feature similar to Instagram's navigation bar defaults to true.


### Curious how the navbar_router works?

Read more in a [medium blog post](https://maheshmnj.medium.com/everything-about-the-bottomnavigationbar-in-flutter-e99e5470dddb) for detailed explanation.


## **Contribution**

  Contributions are welcome to make this package better. For more details on how to contribute, please see the [contributing guide](./CONTRIBUTING.md)
