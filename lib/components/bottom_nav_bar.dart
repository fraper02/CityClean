import 'package:flutter/material.dart';
import '../screens/map_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/home_screen.dart';
import '../screens/events_screen.dart';
import '../screens/ia_screen.dart';

class CityCleanBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CityCleanBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(int index, BuildContext context) {
    if (index == currentIndex) {
      if (index == 2 && ModalRoute.of(context)!.settings.name != '/') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen(), settings: const RouteSettings(name: '/')),
          (route) => false,
        );
      }
      return;
    }

    Widget page;
    switch (index) {
      case 0:
        page = const MapScreen();
        break;
      case 1:
        page = const RewardsScreen();
        break;
      case 2:
        page = const HomeScreen();
        break;
      case 3:
        page = const EventsScreen();
        break;
      case 4:
        page = const IAScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(index, context),
      selectedItemColor: Colors.green[800],
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Mappa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard_outlined),
          activeIcon: Icon(Icons.card_giftcard),
          label: 'Premi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profilo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.event),
          label: 'Eventi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_enhance_outlined),
          activeIcon: Icon(Icons.camera_enhance),
          label: 'IA',
        ),
      ],
    );
  }
}
