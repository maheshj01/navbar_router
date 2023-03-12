## **navbar_router 0.3.3**

 <a href="https://pub.dev/packages/navbar_router"><img src="https://img.shields.io/pub/v/navbar_router.svg" alt="Pub"></a>

This is a NavigationBar widget created by considering the advanced use cases in real world applications. This widget handles the boilerplate code required to handle some of the most common features (specified below) with minimal code and hassle. All you need to do is specify the navbar menu items, routes and destinations and the rest will be taken care by the navbar_router.

## **Features**

- Adapatable to different device Sizes using `isDesktop` and `NavbarDecoration.isExtended` Property.
- Remembers navigation history of Navbar.
- Ability to push routes in the nested or root navigator
- Smooth transitions when changing navbar destinations
- Notifies onBackButtonPress to handle app exits.
- Programmatically control state of bottom navbar from any part of widget tree e.g change index, hide/show bottom navbar, pop routes of a specific tab etc
- persist state across bottom navbar tabs.
- Tapping the same navbar button pops to base route of nested navigator (same as instagram).

_Heres a [sample app](example/lib/main.dart) built using this package to see how it works._

_video demo of the sample app_

<img src="https://miro.medium.com/max/600/1*k_VYc1pqlgZWWm-Ui-gWHA.gif" alt="navbar_route demo"/>


This package will help you save atleast 50% lines of code in half the time required to implement the above features. Heres the same [sample app](https://dartpad.dev/?id=894922ccb67f5fdc4ffb652e41916fa2) without the package which requires around 800 lines of code.

## **Installation**

Run from the root of your flutter project.

```console
  flutter pub add navbar_router
```

*Example*


```dart
class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  List<NavbarItem> items = [
    NavbarItem(Icons.home, 'Home', backgroundColor: colors[0]),
    NavbarItem(Icons.shopping_bag, 'Products', backgroundColor: colors[1]),
    NavbarItem(Icons.person, 'Me', backgroundColor: colors[2]),
  ];

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
        for (int i = 0; i < items.length; i++)
          DestinationRouter(
            navbarItem: items[i],
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

# Features Breakdown

## Remembers NavigationBar history

When the selected NavbarItem is at the root of the navigation stack, pressing the Back button will by default trigger app exit. By specifying

```dart
behavior: BackButtonBehavior.rememberHistory,
```
will switch the navbar current index to the last selected NavbarItem from the navbarHistory.


<img src="https://user-images.githubusercontent.com/31410839/184479993-01c85b2d-4453-4137-93b2-5242d1ed0e7e.gif" width ="300"> 

## Fading between NavbarDestinations

You can have smooth Transitions between NavbarDestinations by setting the `destinationAnimationCurve` and `destinationAnimationDuration` properties.

defaults to

```dart
  destinationAnimationCurve: Curves.fastOutSlowIn,
  destinationAnimationDuration: 700,
```

<img src="https://miro.medium.com/max/600/1*08wCOOPCe1C1l_2uqIYEEg.gif">



## Hide or show bottomNavigationBar

You can hide or show bottom navigationBar with a single line of code from anywhere in the widget tree. This allows you to handle useCases like scroll down to hide the navbar or hide the navbar on opening the drawer.

```dart
 NavbarNotifier.hideBottomNavBar = true;
```

Hide/show navbar on scroll             |  Hide/show navbar on drawer open/close
:-------------------------:|:-------------------------:
![](https://miro.medium.com/max/800/1*NaYdY1FfsPFCNBdx3wg_og.gif)  | <img src="https://user-images.githubusercontent.com/31410839/173987446-c8c79bb0-d24c-46c1-bc4a-582508a4e187.gif" width ="200">


## Notify onBackButtonPress

*navbar_router* provides a `onBackButtonPressed` callback to intercept events from android back button. Giving you the ability to handle app exits (e.g you might want to implement double press back button to exit).

*sample code implementing double press back button to exit*

```dart
      onBackButtonPressed: (isExitingApp) {
        if (isExitingApp) {
          newTime = DateTime.now();
          int difference = newTime.difference(oldTime).inMilliseconds;
          oldTime = newTime;
          if (difference < 1000) {
            hideSnackBar();
            return isExitingApp;
          } else {
            showSnackBar();
            return false;
          }
        } else {
          return isExitingApp;
        }
      },
```

<img src="https://miro.medium.com/max/600/1*NRszUNzsN-HDlDmeJP1IDQ.gif">



## Adapatable to different device Sizes


```dart
 NavbarRouter(
        errorBuilder: (context) {
          return const Center(child: Text('Error 404'));
        },
        isDesktop: size.width > 600 ? true : false,
        decoration: NavbarDecoration(
            isExtended: size.width > 800 ? true : false,
            navbarType: BottomNavigationBarType.shifting),
        ...
        ...
);
```

<img src="https://user-images.githubusercontent.com/31410839/175865246-39b783fd-2030-4bc1-ad87-528db50fe3d7.gif">


## **Docs**

  **backButtonBehavior**:An enum which decides, How the back button is handled, defaults to `BackButtonBehavior.rememberHistory`.

  ***destinations***: A List of `DestinationRouter` to show when the user taps the [NavbarItem].
  Each DestinationRouter specifies a List of Destinations, initialRoute, and the navbarItem corresponding to that destination.

  ***decoration*** : The decoraton for Navbar has all the properties you would expect in a [BottomNavigationBar] to adjust the style of the Navbar.

  ***destinationAnimationCurve***: Curve for the destination animation when the user taps a navbar item. Defaults to `Curves.fastOutSlowIn`.

  ***destinationAnimationDuration***: The duration in milliseconds of the animation of the destination. Defaults to 700ms.

  ***errorBuilder***: A WidgetBuilder to show the user when the user tried to navigate to a route that does not exist in the [destinations].

  **initialIndex**: Navbar item that is initially selected, defaults to the first item in the list of [NavbarItems]

  ***isDesktop***: if true, navbar will be shown on the left, this property can be used along with `NavbarDecoration.isExtended` to make the navbar adaptable for large screen sizes.

  ***onBackButtonPressed***: A function which defines whether it is the root Navigator or not. if the method returns true then the Navigator is at the base of the navigator stack

  ***onChanged***: A callback that is called when the currentIndex of the navbarchanges.

  ***shouldPopToBaseRoute***: A boolean which decides, whether the navbar should pop to the base route (pop all except first) when the current navbar is tapped while the route is deeply nested. This feature is similar to Instagram's navigation bar defaults to true.

### Curious how the navbar_router works?

Read more in a [medium blog post](https://maheshmnj.medium.com/everything-about-the-bottomnavigationbar-in-flutter-e99e5470dddb) for detailed explanation.


## **Contribution**

  Contributions are welcome! for more details on how to contribute, please see the [contributing guide](./CONTRIBUTING.md)
