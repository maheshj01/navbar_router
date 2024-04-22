## [0.7.4] April 30, 2023

- Expose NavigationRail properties

## [0.7.3] Dec 30, 2023

- Prevent unwanted rebuilds of NavbarItem

## [0.7.2] Dec 25, 2023

- Compare widget runtimeType to prevent unnecessary rebuilds

## [0.7.1] Dec 20, 2023

- Rebuild Navbar on updating its properties Fixes: [Issue #38](https://github.com/maheshmnj/navbar_router/issues/38)
- Remove workaround for [Issue #17](https://github.com/maheshmnj/navbar_router/issues/17)
- Add child parameter to NavbarItem for adding custom widgets in place of icon and label Fix [Issue #20](ttps://github.com/maheshmnj/navbar_router/issues/20)
- Add selectedIcon property to NavbarItem

## [0.7.0] Dec 08, 2023

- Fixes: [Issue #6](https://github.com/maheshmnj/navbar_router/issues/6) Fade Transition is not smooth

## [0.6.3] Nov 14, 2023

- Add a method to programmatically push a route to the NavigatorStack

## [0.6.2] Nov 04, 2023

- Fix: NavigationBar height is too much [Issue #17](https://github.com/maheshmnj/navbar_router/issues/17)

## [0.6.1] Aug 12, 2023

- Configure `FloatingNavbar` height with `FloatingNavbarDecoration.height` property

## [0.6.0] July 29, 2023

- Adds support for Floating Navbar with `NavbarType.floating`

## [0.5.9] July 21, 2023

- Adds `transitionDuration` property to `Navigate` class

## [0.5.8] July 21, 2023

- add circular reveal transition animation
- rename `slideTransitionType` to `transitionType` for `pushReplace` method
- Add `Offset` property for `TransitionType.reveal`

## [0.5.7] July 04, 2023

- Expose onClosed property of Snackbar api.
- Expose `onCurrentTabClicked` property of NavbarRouter

## [0.5.6] June 25, 2023

- Adds support for Floating Snackbar on top of NavbarRouter

## [0.5.5] June 11, 2023

- Fix theme of NavbarRouter in Desktop mode (Material 3)

## [0.5.4] June 10, 2023

- Revert: removes `'isRootNavigator` from Named Routes

## [0.5.3] June 10, 2023

- deprecate `navigate` method in favor of `Navigate` class
- Adds Navigate.pushReplaceNamed method
- removes `'isRootNavigator` from Named Routes

## [0.5.2] June 4, 2023

- Adds `Navigate` class to help with navigation with transitions.
- Fix M3Navbar Color scheme to match M3 spec
- Fix: Notched Navbar Shape [Issue #19](https://github.com/maheshmnj/navbar_router/issues/19)
- Migrate example app to material 3

## [0.5.1] May 21, 2023

- Defines global navbar height constants `kStandardNavbarHeight`, `kM3NavbarHeight`, `kNotchedNavbarHeight`.

## [0.5.0] Apr 08, 2023

- Adds support for material3 navbar
- Removes selectedLabelColor Property
- Adds indexChangeListener to NavbarRouter

## [0.4.2] Jan 25, 2023

- Update default decoration values

## [0.4.1] Dec 26, 2022

- Improve NavbarType.notched shape and selected icon accuracy

## [0.4.0] Dec 25, 2022

- [WIP Ref Issue:#8](https://github.com/maheshmnj/navbar_router/issues/8) Adds support for custom Navbar using `NavbarRouter.type: NavbarType.notched`

## [0.3.3] Aug 14, 2022

- Pop route programmatically

## [0.3.2] Aug 14, 2022

- update docs

## [0.3.1] Aug 14, 2022

- Fix back button did not pop up nested routes
- add `initialIndex` property

## [0.3.0] Aug 7, 2022

- Remember stack history on back button press [Issue #9](https://github.com/maheshmnj/navbar_router/issues/9)

## [0.2.2] Jul 9, 2022

- Remove unnecessary shadow from BottomNavigationBar.

## [0.2.1] Jul 2, 2022

- Add `onChanged` callback to `NavbarRouter`
- Add decoration properties to `NavbarDecoration`

## [0.2.0] Jun 26, 2022

- Add `isDesktop` property to make navbar adaptable
  to different screen sizes.

## [0.1.2] Jun 16, 2022

- update docs and example
- fix linter warnings

## [0.1.0] Jun 15, 2022

- initial release.

## [0.1.1] Jun 15, 2022

- Update dart constraints
