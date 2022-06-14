### navbar_router

This is the ultimate BottomNavigionBar which allow you to focus on the logic of your app than having to worry about writing the boilerplate code to make the user experience better. This widget helps you cover the most common use cases of BottomNavigationBar with minimal code and hassle.


_Heres a [sample app](example/lib/main.dart) built using this package to see how it works._

_video demo of sample app_


https://user-images.githubusercontent.com/31410839/170913498-f1094090-bd80-43e6-ba09-7aa3dea029ba.mp4

### Features

- Ability to push routes in the nested or root navigator
- Notifies onBackButtonPress to handle app exits like a pro
- Ability to hide or show bottomNavigationBar in a single line of code
- maintain state across bottom navbar tabs
- Tapping the same navbar button pops to base route of nested navigator (same as instagram)
- Switch the Navbar destination with animation


### Api docs

  *destinations*: A Nested List of Destinations to show when the user taps the [NavbarItem]

  *errorBuilder*: A WidgetBuilder to show the user when the user tried to navigate to a route that does not exist in the [destinations].

  items: navbar Items to show in the navbar

   *onBackButtonPressed*: A Function which defines whether it is the root Navigator or not
   if the method returns true then the Navigator is at the base of the navigator stack

   *shouldPopToBaseRoute*: A boolean which decides, whether the navbar should pop all routes except first
 when the current navbar is tapped while the route is deeply nested
 feature similar to Instagram's navigation bar
 defaults to true.


### Curious how does the navbar_router work? 

Read more in a [medium blog post](https://maheshmnj.medium.com/everything-about-the-bottomnavigationbar-in-flutter-e99e5470dddb) for detailed explanation.
