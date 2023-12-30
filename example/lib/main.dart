import 'dart:async';
import 'dart:developer';

import 'package:example/app_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';

void main() {
  runApp(ProviderScope(
    child: MyApp(),
  ));
}

final appProvider = StateNotifierProvider<AppNotifier, AppController>(
    (ref) => AppNotifier(AppController(
          extended: false,
          index: 0,
          showFAB: true,
        )));

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final List<Color> colors = [mediumPurple, Colors.orange, Colors.teal];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: appSetting,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
              title: 'BottomNavbar Demo',
              routes: {
                ProfileEdit.route: (context) => const ProfileEdit(),
              },
              themeMode:
                  appSetting.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              darkTheme: ThemeData.dark(
                useMaterial3: true,
              ).copyWith(
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: appSetting.themeSeed,
                      brightness: Brightness.dark)),
              theme: ThemeData(
                  useMaterial3: true,
                  primaryColorDark: appSetting.themeSeed,
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: appSetting.themeSeed)),
              home: const HomePage());
        });
    // home: const NavbarSample(title: 'BottomNavbar Demo'));
  }
}

AppSetting appSetting = AppSetting();
final List<Color> themeColorSeed = [
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.teal,
  Colors.pink,
  Colors.indigo,
  Colors.brown,
  Colors.cyan,
  Colors.deepOrange,
  Colors.deepPurple,
  Colors.lime,
  Colors.amber,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.yellow,
  Colors.grey,
];

class AppSetting extends ChangeNotifier {
  bool isDarkMode;
  Color themeSeed = Colors.blue;

  AppSetting({this.isDarkMode = false});

  void changeThemeSeed(Color color) {
    themeSeed = color;
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<NavbarItem> items = [
    NavbarItem(Icons.home_outlined, 'Home',
        backgroundColor: colors[0],
        selectedIcon: const Icon(
          Icons.home,
          size: 26,
        )),
    NavbarItem(Icons.shopping_bag_outlined, 'Products',
        backgroundColor: colors[1],
        selectedIcon: const Icon(
          Icons.shopping_bag,
          size: 26,
        )),
    NavbarItem(Icons.person_outline, 'Me',
        backgroundColor: colors[2],
        selectedIcon: const Icon(
          Icons.person,
          size: 26,
        )),
    NavbarItem(Icons.settings_outlined, 'Settings',
        backgroundColor: colors[0],
        selectedIcon: const Icon(
          Icons.settings,
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
      ProductComments.route: ProductComments(),
    },
    2: {
      '/': UserProfile(),
      ProfileEdit.route: ProfileEdit(),
    },
    3: {
      '/': Settings(),
    },
  };

  DateTime oldTime = DateTime.now();
  DateTime newTime = DateTime.now();

  /// This is only for demo purposes
  void simulateTabChange({int times = 2, int delayInMs = 1000}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      for (int i = 0; i < items.length * times; i++) {
        NavbarNotifier.index = i % items.length;
        await Future.delayed(Duration(milliseconds: delayInMs));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // simulateTabChange(times: 1, delayInMs: 2000);
    NavbarNotifier.addIndexChangeListener((x) {
      log('NavbarNotifier.indexChangeListener: $x');
    });
  }

  @override
  void dispose() {
    NavbarNotifier.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appRef = ref.watch(appProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: AnimatedBuilder(
          animation: NavbarNotifier(),
          builder: (context, child) {
            if (!appRef.showFAB || appRef.index < 2) {
              return Padding(
                padding: EdgeInsets.only(bottom: kNavbarHeight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 100,
                    ),
                    FloatingActionButton.extended(
                      heroTag: 'showSnackBar',
                      onPressed: () {
                        final state = Scaffold.of(context);
                        NavbarNotifier.showSnackBar(
                          context,
                          "This is shown on top of the Floating Action Button",
                          bottom:
                              state.hasFloatingActionButton ? 0 : kNavbarHeight,
                        );
                      },
                      label: const Text("Show SnackBar"),
                    ),
                    FloatingActionButton(
                      heroTag: 'navbar',
                      child: Icon(NavbarNotifier.isNavbarHidden
                          ? Icons.toggle_off
                          : Icons.toggle_on),
                      onPressed: () {
                        // Programmatically toggle the Navbar visibility
                        if (NavbarNotifier.isNavbarHidden) {
                          NavbarNotifier.hideBottomNavBar = false;
                        } else {
                          NavbarNotifier.hideBottomNavBar = true;
                        }
                        setState(() {});
                      },
                    ),
                    FloatingActionButton(
                      heroTag: 'darkmode',
                      child: Icon(appSetting.isDarkMode
                          ? Icons.wb_sunny
                          : Icons.nightlight_round),
                      onPressed: () {
                        appSetting.toggleTheme();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),
      body: NavbarRouter(
        errorBuilder: (context) {
          return const Center(child: Text('Error 404'));
        },
        isDesktop: size.width > 600 ? true : false,
        onBackButtonPressed: (isExitingApp) {
          if (isExitingApp) {
            newTime = DateTime.now();
            int difference = newTime.difference(oldTime).inMilliseconds;
            oldTime = newTime;
            if (difference < 1000) {
              NavbarNotifier.hideSnackBar(context);
              return isExitingApp;
            } else {
              final state = Scaffold.of(context);
              NavbarNotifier.showSnackBar(
                context,
                "Tap back button again to exit",
                bottom: state.hasFloatingActionButton ? 0 : kNavbarHeight,
              );
              return false;
            }
          } else {
            return isExitingApp;
          }
        },
        initialIndex: 0,
        type: NavbarType.floating,
        destinationAnimationCurve: Curves.fastOutSlowIn,
        destinationAnimationDuration: 200,
        decoration: FloatingNavbarDecoration(
          height: 80,
          borderRadius: BorderRadius.circular(20),
          isExtended: size.width > 800 ? true : false,
          // labelTextStyle: const TextStyle(
          //     color: Color.fromARGB(255, 176, 207, 233), fontSize: 14),
          // elevation: 3.0,
          // indicatorShape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.all(Radius.circular(20)),
          // ),
          showSelectedLabels: false,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          // indicatorColor: const Color.fromARGB(255, 176, 207, 233),
          // // iconTheme: const IconThemeData(color: Colors.indigo),
          // /// labelTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
          // labelBehavior: NavigationDestinationLabelBehavior.alwaysShow
        ),
        onChanged: (x) {
          ref.read(appProvider.notifier).setIndex(x);
        },
        backButtonBehavior: BackButtonBehavior.rememberHistory,
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
      ),
    );
  }
}

const Color mediumPurple = Color.fromRGBO(79, 0, 241, 1.0);
const String placeHolderText =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';

class HomeFeeds extends StatefulWidget {
  const HomeFeeds({Key? key}) : super(key: key);
  static const String route = '/';

  @override
  State<HomeFeeds> createState() => _HomeFeedsState();
}

class _HomeFeedsState extends State<HomeFeeds> {
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    if (size.width < 600) {
      _addScrollListener();
    }
  }

  void handleScroll() {
    if (size.width > 600) return;
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (NavbarNotifier.isNavbarHidden) {
        NavbarNotifier.hideBottomNavBar = false;
      }
    } else {
      if (!NavbarNotifier.isNavbarHidden) {
        NavbarNotifier.hideBottomNavBar = true;
      }
    }
  }

  void _addScrollListener() {
    _scrollController.addListener(handleScroll);
  }

  Size size = Size.zero;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeds'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: 30,
        itemBuilder: (context, index) {
          return InkWell(
              onTap: () {
                NavbarNotifier.hideBottomNavBar = false;
                Navigate.push(
                    context,
                    FeedDetail(
                      feedId: index.toString(),
                    ),
                    isRootNavigator: false,
                    transitionType: TransitionType.reveal);
              },
              child: FeedTile(
                index: index,
              ));
        },
      ),
    );
  }
}

class FeedTile extends StatelessWidget {
  final int index;
  const FeedTile({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: Card(
        child: Column(
          children: [
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text('Feed $index card'),
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.center,
                child: Text(
                  placeHolderText.substring(0, 200),
                  textAlign: TextAlign.justify,
                ))
          ],
        ),
      ),
    );
  }
}

class FeedDetail extends StatelessWidget {
  final String feedId;
  const FeedDetail({Key? key, this.feedId = '1'}) : super(key: key);
  static const String route = '/feeds/detail';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed $feedId'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Placeholder(
                fallbackHeight: 200,
                fallbackWidth: 300,
              ),
              Text(placeHolderText),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductList extends ConsumerStatefulWidget {
  const ProductList({super.key});
  static const String route = '/';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductList> {
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    size = MediaQuery.of(context).size;
    if (size.width < 600) {
      _addScrollListener();
    }
  }

  void handleScroll() {
    if (size.width > 600) return;
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (NavbarNotifier.isNavbarHidden) {
        NavbarNotifier.hideBottomNavBar = false;
      }
    } else {
      if (!NavbarNotifier.isNavbarHidden) {
        NavbarNotifier.hideBottomNavBar = true;
      }
    }
  }

  void _addScrollListener() {
    _scrollController.addListener(handleScroll);
  }

  Size size = Size.zero;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("productlist initState invoked");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: ListView.builder(
          controller: _scrollController,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      NavbarNotifier.pushNamed(FeedDetail.route, 0);
                      NavbarNotifier.showSnackBar(context, 'switching to Home',
                          onClosed: () {
                        NavbarNotifier.index = 0;
                      });
                    } else {
                      NavbarNotifier.hideBottomNavBar = false;
                      Navigate.pushNamed(context, ProductDetail.route,
                          transitionType: TransitionType.scale,
                          arguments: {'id': index.toString()});
                    }
                  },
                  child: ProductTile(index: index)),
            );
          }),
    );
  }
}

class ProductTile extends StatelessWidget {
  final int index;
  const ProductTile({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                height: 75,
                width: 75,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Flexible(
                child: Text(
                  index != 0
                      ? 'Product $index'
                      : 'Tap to push a route on HomePage Programmatically',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          )),
    );
  }
}

class ProductDetail extends StatelessWidget {
  final String id;
  const ProductDetail({Key? key, this.id = '1'}) : super(key: key);
  static const String route = '/products/detail';
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final argsId = args['id'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Product $argsId'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('My AWESOME Product $argsId'),
          const Center(
            child: Placeholder(
              fallbackHeight: 200,
              fallbackWidth: 300,
            ),
          ),
          TextButton(
              onPressed: () {
                NavbarNotifier.hideBottomNavBar = false;
                Navigate.pushNamed(context, ProductComments.route,
                    arguments: {'id': argsId.toString()});
              },
              child: const Text('show comments'))
        ],
      ),
    );
  }
}

class ProductComments extends StatelessWidget {
  final String id;
  const ProductComments({Key? key, this.id = '1'}) : super(key: key);
  static const String route = '/products/detail/comments';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments on Product $id'),
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 60,
            child: ListTile(
              tileColor: Theme.of(context).colorScheme.secondaryContainer,
              title: Text('Comment $index'),
            ),
          ),
        );
      }),
    );
  }
}

class UserProfile extends StatefulWidget {
  static const String route = '/';

  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey iconKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("profile initState invoked");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      appBar: AppBar(
          centerTitle: false,
          actions: [
            IconButton(
              key: iconKey,
              icon: const Icon(Icons.edit),
              onPressed: () {
                final RenderBox? renderBox =
                    iconKey.currentContext!.findRenderObject() as RenderBox?;
                final offset = renderBox!.localToGlobal(Offset.zero);
                Navigate.push(context, const ProfileEdit(),
                    isRootNavigator: true,
                    offset: offset,
                    transitionType: TransitionType.reveal);
              },
            )
          ],
          title: const Text('Hi User')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Hi! This is your Profile Page'),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () {
                  NavbarNotifier.showSnackBar(
                    context,
                    "This is a Floating SnackBar",
                    actionLabel: "Tap to close",
                    onActionPressed: () {
                      NavbarNotifier.hideSnackBar(context);
                    },
                    bottom: NavbarNotifier.currentIndex > 1 ? kNavbarHeight : 0,
                  );
                },
                child: const Text('Show SnackBar')),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
                onPressed: () {
                  NavbarNotifier.popRoute(1);
                },
                child: const Text('Pop Product Route')),
          ],
        ),
      ),
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  double index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          actions: [
            Switch(
                value: appSetting.isDarkMode,
                onChanged: (x) {
                  appSetting.toggleTheme();
                  setState(() {});
                })
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Slide to change theme color',
                  style: TextStyle(fontSize: 20, color: appSetting.themeSeed)),
              const SizedBox(
                height: 20,
              ),
              CupertinoSlider(
                  value: index,
                  min: 0,
                  thumbColor: appSetting.themeSeed,
                  max: themeColorSeed.length.toDouble() - 1,
                  onChanged: (x) {
                    setState(() {
                      index = x;
                    });
                    appSetting.changeThemeSeed(themeColorSeed[index.toInt()]);
                  })
            ],
          ),
        ));
  }
}

class ProfileEdit extends StatelessWidget {
  static const String route = '/profile/edit';

  const ProfileEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Edit')),
      body: const Center(
        child: Text('Notice this page does not have bottom navigation bar'),
      ),
    );
  }
}
