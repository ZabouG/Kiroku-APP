import 'package:flutter/material.dart';
import 'homePage.dart';
import 'profilPage.dart';
import 'searchPage.dart';

/// Barre de navigation principale de l'application
class NavigationBarApp extends StatefulWidget {
  const NavigationBarApp({Key? key}) : super(key: key);

  @override
  State<NavigationBarApp> createState() => _NavigationBarAppState();
}

class _NavigationBarAppState extends State<NavigationBarApp> {
  int currentPageIndex = 0;

  /// Liste des pages
  final List<Widget> pages = const [
    HomePage(),
    SearchPage(),
    ProfilPage(),
  ];

  /// Liste des destinations de la barre de navigation
  final List<NavigationDestination> destinations = const [
    NavigationDestination(
      selectedIcon: Icon(Icons.home),
      icon: Icon(Icons.home_outlined),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.search),
      label: 'Rechercher',
    ),
    NavigationDestination(
      icon: Icon(Icons.account_circle),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentPageIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.deepPurple.shade100,
        destinations: destinations,
      ),
    );
  }
}
