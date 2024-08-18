## **navbar_router v0.7.6**

<a href="https://github.com/maheshmnj/searchfield" rel="noopener" target="_blank"><img src="https://img.shields.io/badge/platform-flutter-ff69b4.svg" alt="Flutter Platform Badge"></a>
<a href="https://pub.dev/packages/navbar_router"><img src="https://img.shields.io/pub/v/navbar_router.svg" alt="Pub"></a>
[![codecov](https://codecov.io/gh/maheshmnj/navbar_router/graph/badge.svg?token=B28CW4KRYS)](https://codecov.io/gh/maheshmnj/navbar_router)
[![Build](https://github.com/maheshmnj/navbar_router/actions/workflows/build.yml/badge.svg)](https://github.com/maheshmnj/navbar_router/actions/workflows/build.yml)
<a href="https://opensource.org/licenses/MIT" rel="noopener" target="_blank"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="MIT License Badge"></a>

![Floating
  Navbar](https://github.com/maheshmnj/navbar_router/assets/31410839/7da504ae-4894-481c-a443-01a24fc61946)

_Checkout our [extensive docs](https://docs.maheshjamdade.com/navbar_router/) to learn more about this package, the inspiration behind it and how to use it._

## Adding a BottomNavigationBar to your app?

NavbarRouter is a complete package to handle all your BottomNavigationBar needs. It provides a simplest api to achieve the advanced features of BottomNavigationBar making the user experience of your app much better. You only need to specify the NavbarItems and the routes for each NavbarItem and NavbarRouter will take care of the rest.

_Most of the features which this package provides are mainly to improve the user experience by handling the smallest things possible._

See the [demo app here](https://navbar-router.netlify.app/)

## **Key Features**

- Choose between different NavigationBar types.
- Remembers navigation history of Navbar (Android).
- Persist Navbar when pushing routes
- Support for nested navigation.
- Intercept back button press to handle app exits (Android).
- Fade smoothly between NavbarDestinations
- show different icons for selected and unselected NavbarItems.
- Consistent API for all types of Navbar.
- Programmatically control state of bottom navbar from any part of widget tree e.g change index, hide/show bottom navbar,push/pop routes of a specific tab etc
- Show Snackbar messages on top of Navbar with a single line of code.
- persist state across bottom navbar tabs.
- Jump to base route from a deep nested route with a single tap(same as instagram).
- Adapatable to different device Sizes.
- Supports badges on the NavbarItems.

## Supports mulitple NavbarTypes

You can choose between different NavbarTypes using the `NavbarDecoration.navbarType` property. This allows you to choose between the default `NavbarType.standard` and `NavbarType.notched` NavbarTypes.

|                                            NavbarType.standard (default)                                            |                                                 NavbarType.notched                                                 |
| :-----------------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------: |
| ![Standard Navbar](https://github.com/maheshmnj/navbar_router/assets/31410839/62d6154f-dcf5-4aa9-a819-e2c84caebad1) | ![Notched Navbar](https://github.com/maheshmnj/navbar_router/assets/31410839/5378f9cd-a6ac-4c6b-bd2a-a706e87b89eb) |

|                                                 NavbarType.material3                                                 |                                                 NavbarType.floating                                                 |
| :------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------: |
| ![Material3 Navbar](https://github.com/maheshmnj/navbar_router/assets/31410839/027adf4f-d527-4dc5-ac22-8fe321734977) | ![Floating Navbar](https://github.com/maheshmnj/navbar_router/assets/31410839/d439f3d2-1c1c-448e-bbf0-cb73b372f76d) |

_Heres a [sample app](example/lib/main.dart) built using this package to see how it works._

_video demo of the sample app_

<img src="https://github.com/maheshmnj/navbar_router/assets/31410839/d7490227-34b5-4954-b43b-f4fdcffdacd3" alt="navbar_route demo" width="300"/>

This package will help you save atleast 50% lines of code in half the time required to implement the above features. Heres the same [sample app](https://dartpad.dev/?id=894922ccb67f5fdc4ffb652e41916fa2) without the package which requires around 800 lines of code.

## **Installation**

Run from the root of your flutter project.

```console
  flutter pub add navbar_router
```

_Example_

```dart
class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  List<NavbarItem> items = [
    NavbarItem(Icons.home_outlined, 'Home',
        backgroundColor: mediumPurple,
        selectedIcon: Icon(
          Icons.home,
          size: 26,
        )),
    NavbarItem(Icons.shopping_bag_outlined, 'Products',
        backgroundColor: Colors.orange,
        selectedIcon: Icon(
          Icons.shopping_bag,
          size: 26,
        )),
    NavbarItem(Icons.person_outline, 'Me',
        backgroundColor: Colors.teal,
        selectedIcon: Icon(
          Icons.person,
          size: 26,
        )),
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

- `BackButtonBehavior.rememberHistory`,
  This will switch the navbar current index to the last selected NavbarItem (Tab 2) from the navbarHistory.

<img src="https://user-images.githubusercontent.com/31410839/184479993-01c85b2d-4453-4137-93b2-5242d1ed0e7e.gif" width ="300">

You can read [more about this feature here.](https://github.com/maheshmnj/navbar_router/issues/9#issuecomment-1211569478)

## Fading between NavbarDestinations

You can have smooth Transitions between NavbarDestinations by setting the `destinationAnimationCurve` and `destinationAnimationDuration` properties.

defaults to

```dart
  destinationAnimationCurve: Curves.fastOutSlowIn,
  destinationAnimationDuration: 300,
```

<img width="300" src="https://github.com/flutter/flutter/assets/31410839/90e2d176-cd62-4e0f-8b3c-6afa64c96330">

## Hide or show bottomNavigationBar

You can hide or show bottom navigationBar with a single line of code from anywhere in the widget tree. This allows you to handle useCases like scroll down to hide the navbar or hide the navbar on opening the drawer.

```dart
 NavbarNotifier.hideBottomNavBar = true;
```

|                    Hide/show navbar on scroll                     |                                             Hide/show navbar on drawer open/close                                              |                                           Consistent behavior across all Navbars                                           |
| :---------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------: |
| ![](https://miro.medium.com/max/800/1*NaYdY1FfsPFCNBdx3wg_og.gif) | <img src="https://user-images.githubusercontent.com/31410839/173987446-c8c79bb0-d24c-46c1-bc4a-582508a4e187.gif" width ="200"> | ![ezgif com-video-to-gif](https://github.com/maheshmnj/navbar_router/assets/31410839/4e30d2a6-63c7-427c-953b-f800d1b68fad) |

## Show Snackbar

You can show a snackbar on top of the navbar by using the `NavbarNotifier.showSnackBar` method.

![snackbar](https://github.com/flutter/flutter/assets/31410839/b2c95c3b-45fa-474c-acee-6f48a051f8ef)

Note: You will need to wrap your NavbarRouter within a builder for this to work see the [example](example/lib/main.dart) for more details.

```dart
NavbarNotifier.showSnackBar(
  context,
  "This is shown on top of the Floating Action Button",
  /// offset from bottom of the screen
  bottom: state.hasFloatingActionButton ? 0 : kNavbarHeight,
);
```

And hide it using the `NavbarNotifier.hideSnackBar` method.

```dart
NavbarNotifier.hideSnackBar(context);
```

## Intercept BackButton press events (Android)

_navbar_router_ provides a `onBackButtonPressed` callback to intercept events from android back button, giving you the ability to handle app exits so as to prevent abrupt app exits without users consent. (or you might want to implement double press back button to exit).
This callback method must return `true` to exit the app and false other wise.

_sample code implementing double press back button to exit_

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

## Adds Support for Animated Navbar Badges

<img width="537" alt="image" src="https://github.com/maheshmnj/navbar_router/assets/31410839/6d8d28fa-e30c-498e-9216-91dc9b6765ea">

![ScreenRecording2024-04-24at09 32 06-ezgif com-crop](https://github.com/maheshmnj/navbar_router/assets/31410839/d993f6cf-7f91-4f97-b453-fb4d3b18260e)

```dart
NavbarItem(Icons.home_outlined, 'Home',
      backgroundColor: colors[0],
      selectedIcon: const Icon(
        Icons.home,
        size: 26,
      ),
      badge: const NavbarBadge(
        badgeText: "11",
        showBadge: true,
      )),
```

- Show or hide the badge using the `NavbarNotifier.makeBadgeVisible` and update using `NavbarNotifier.updateBadge` method from any part of the tree.

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

<img src="https://github.com/maheshmnj/navbar_router/assets/31410839/2362187a-0a19-41a0-938c-214c103e64dd">

For detailed description of all the features and properties please visit the [documentation](https://docs.maheshjamdade.com/navbar_router)

### Curious how the navbar_router works?

Read more in a [medium blog post](https://maheshmnj.medium.com/everything-about-the-bottomnavigationbar-in-flutter-e99e5470dddb) for detailed explanation.

Youtube: [Heres a discussion](https://www.youtube.com/watch?v=IhlikgW8OY8&t=614s) I had with [Allen Wyma](https://twitter.com/fhwflutter) from Flying high with Fluter regarding this package.

## **Contribution**

Contributions are welcome! for more details on how to contribute, please see the [contributing guide](./CONTRIBUTING.md)
