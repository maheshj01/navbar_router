## **navbar_router 0.4.1**

 <a href="https://pub.dev/packages/navbar_router"><img src="https://img.shields.io/pub/v/navbar_router.svg" alt="Pub"></a>

This is a custom BottomNavigationBar created by considering most of the common use cases of BottomNavigationBar in real world applications. This widget handles the boilerplate code required to handle some of the most common features (specified below) with minimal code and hassle. All you need to do is specify the navbar menu items, routes and destinations and the rest will be taken care by the navbar_router.

Most of the features which this package provides are mainly to improve the user experience by handling the smallest things possible.

## **Features**

- Choose between different NavigationBar types.
- Remembers navigation history of Navbar (Android).
- Ability to push routes in the nested or root navigator
- Intercept back button press to handle app exits (Android).
- Fading between NavbarDestinations
- Programmatically control state of bottom navbar from any part of widget tree e.g change index, hide/show bottom navbar, pop routes of a specific tab etc
- persist state across bottom navbar tabs.
- Jump to base route from a deep nested route with a single tap(same as instagram).
- Adapatable to different device Sizes.

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

## Remembers NavigationBar history (for Android Devices)

When the selected NavbarItem is at the root of the navigation stack, pressing the Back button (On Android) will by default trigger app exit.

For instance:

Your app has three tabs and you navigate from Tab1 -> Tab2 -> Tab3

- `BackButtonBehavior.exit` (default)
 when you press Back Button (on Tab3) your app will exit

- `behavior: BackButtonBehavior.rememberHistory`,
 This will switch the navbar current index to the last selected NavbarItem (Tab 2) from the navbarHistory.

<img src="https://user-images.githubusercontent.com/31410839/184479993-01c85b2d-4453-4137-93b2-5242d1ed0e7e.gif" width ="300">

You can read [more about this feature here.](https://github.com/maheshmnj/navbar_router/issues/9#issuecomment-1211569478)

## Fading between NavbarDestinations

You can have smooth Transitions between NavbarDestinations by setting the `destinationAnimationCurve` and `destinationAnimationDuration` properties.

defaults to

```dart
  destinationAnimationCurve: Curves.fastOutSlowIn,
  destinationAnimationDuration: 700,
```

<img src="https://miro.medium.com/max/600/1*08wCOOPCe1C1l_2uqIYEEg.gif">


## Choose between different NavbarTypes

You can choose between different NavbarTypes using the `NavbarDecoration.navbarType` property. This allows you to choose between the default `NavbarType.standard` and `NavbarType.notched` NavbarTypes.

### NavbarType.standard (default)

![ezgif com-gif-maker (1)](https://user-images.githubusercontent.com/31410839/209458339-d66524c4-2897-4136-a70f-275d5b6f786e.gif)


### NavbarType.notched

![ezgif com-gif-maker (2)](https://user-images.githubusercontent.com/31410839/209575300-8bafdae7-5465-4dd1-85bc-15065201ff37.gif)


## Hide or show bottomNavigationBar

You can hide or show bottom navigationBar with a single line of code from anywhere in the widget tree. This allows you to handle useCases like scroll down to hide the navbar or hide the navbar on opening the drawer.

```dart
 NavbarNotifier.hideBottomNavBar = true;
```

Hide/show navbar on scroll     |     Hide/show navbar on drawer open/close
:-------------------------:|:-------------------------:
![](https://miro.medium.com/max/800/1*NaYdY1FfsPFCNBdx3wg_og.gif)  | <img src="https://user-images.githubusercontent.com/31410839/173987446-c8c79bb0-d24c-46c1-bc4a-582508a4e187.gif" width ="200">


##  Intercept BackButton press events (Android)

*navbar_router* provides a `onBackButtonPressed` callback to intercept events from android back button, giving you the ability to handle app exits so as to prevent abrupt app exits without users consent. (or you might want to implement double press back button to exit).
This callback method must return `true` to exit the app and false other wise.

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

  **type**: The type of NavigationBar to be passed to NavbarRouter defaults to `NavbarType.standard`. This allows you to choose between the default `NavbarType.standard` and `NavbarType.notched`.

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

Youtube: [Heres a discussion](https://www.youtube.com/watch?v=IhlikgW8OY8) I had with Allen Wyma from Flying high with Fluter regarding this package. 

## **Contribution**

  Contributions are welcome! for more details on how to contribute, please see the [contributing guide](./CONTRIBUTING.md)
