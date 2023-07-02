## [0.5.6] June 27, 2023 (Unreleased)

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
- Fix: Notched Navbar Shape [Issue 19](https://github.com/maheshmnj/navbar_router/issues/19)
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

- [WIP Ref:#8](https://github.com/maheshmnj/navbar_router/issues/8) Adds support for custom Navbar using `NavbarRouter.type: NavbarType.notched`

## [0.3.3] Aug 14, 2022

- Pop route programmatically

## [0.3.2] Aug 14, 2022

- update docs

## [0.3.1] Aug 14, 2022

- Fix back button did not pop up nested routes
- add `initialIndex` property

## [0.3.0] Aug 7, 2022

- Remember stack history on back button press [Issue 9](https://github.com/maheshmnj/navbar_router/issues/9)

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
