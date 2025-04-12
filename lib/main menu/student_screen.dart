import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:library01/common%20screens/authors_screen.dart';
import 'package:library01/student/bookshelf_screen.dart';
import 'package:library01/student/profile_screen.dart';
import 'package:library01/student/student_home.dart';
import 'package:library01/common%20screens/subject_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key, required String userEmail});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);

  final List<Widget> _pages = [
    const StudentHomePage(),
    const SubjectsScreen(),
    const AuthorsPage(),
    const BookshelfScreen(),
    const StudentProfileScreen(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
            inActiveItem: Icon(Icons.menu_book, color: Colors.white),
            activeItem: Icon(Icons.menu_book, color: Colors.deepPurple),
            itemLabel: 'Browse',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.person, color: Colors.white),
            activeItem: Icon(Icons.person, color: Colors.deepPurple),
            itemLabel: 'Authors',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.book, color: Colors.white),
            activeItem: Icon(Icons.book, color: Colors.deepPurple),
            itemLabel: 'Bookshelf',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.account_circle, color: Colors.white),
            activeItem: Icon(Icons.account_circle, color: Colors.deepPurple),
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
