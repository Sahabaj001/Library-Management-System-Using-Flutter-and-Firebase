import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:library01/common%20screens/authors_screen.dart';
import 'package:library01/common%20screens/subject_screen.dart';
import '../librarian/librarian_home.dart';
import '../librarian/librarian_profile_screen.dart';

class LibrarianScreen extends StatefulWidget {
  const LibrarianScreen({super.key, required String librarianEmail});

  @override
  LibrarianScreenState createState() => LibrarianScreenState();
}

class LibrarianScreenState extends State<LibrarianScreen> {
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  final List<Widget> _pages = [
    const LibrarianHome(librarianName: 'Sahabaj'),
    const SubjectsScreen(),
    const AuthorsPage(),
    const LibrarianProfileScreen(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.ease));

          return SlideTransition(position: offsetAnimation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _controller,
        color: Colors.purpleAccent,
        showLabel: true,
        notchColor: Colors.white,
        kIconSize: 24,
        kBottomRadius: 28.0,
        removeMargins: false,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.home, color: Colors.white),
            activeItem: Icon(Icons.home, color: Colors.deepPurple),
            itemLabel: 'Home',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.book, color: Colors.white),
            activeItem: Icon(Icons.book, color: Colors.deepPurple),
            itemLabel: 'Books',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.person_search, color: Colors.white),
            activeItem: Icon(Icons.person_search, color: Colors.deepPurple),
            itemLabel: 'Authors',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.person, color: Colors.white),
            activeItem: Icon(Icons.person, color: Colors.deepPurple),
            itemLabel: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _controller.index = index;
          });
        },
      ),
    );
  }
}
