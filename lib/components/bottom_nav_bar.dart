import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/events_screen.dart';
import '../screens/ia_screen.dart';
import '../screens/map_screen.dart';

class CityCleanBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CityCleanBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Colors.green[700]!;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: primaryGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == currentIndex) return;

        switch (index) {
          case 0: // CASO MAPPA
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const MapScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const RewardsScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const ProfileScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const EventsScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => const IAScreen(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          label: 'Mappa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_giftcard),
          label: 'Premi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profilo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: 'Eventi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_enhance),
          label: 'IA',
        ),
      ],
    );
  }
}