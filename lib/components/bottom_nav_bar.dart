import 'package:cityclean/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../screens/rewards_screen.dart';
import '../screens/events_screen.dart';
import '../screens/ia_screen.dart';
import '../screens/map_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(int index, BuildContext context) {
    if (index == currentIndex) return; // Non ricaricare la stessa pagina

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
        transitionDuration: Duration.zero, // Nessuna animazione
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
      type: BottomNavigationBarType.fixed, // Mantiene lo stile anche con più items
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Mappa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard_outlined),
          activeIcon: Icon(Icons.card_giftcard),
          label: 'Premi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_enhance_outlined),
          activeIcon: Icon(Icons.event),
          label: 'Eventi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.camera_enhance),
          label: 'IA',
        ),
      ],
    );
  }
}
