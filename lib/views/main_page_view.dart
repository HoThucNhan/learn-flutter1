import 'package:flutter/material.dart';
import 'package:learn_flutter1/constants/data_ui.dart';
import 'package:learn_flutter1/views/UserView.dart';
import 'package:learn_flutter1/views/calendar_view.dart';
import 'package:learn_flutter1/views/notes/create_update_task_view.dart';
import 'package:learn_flutter1/views/notes/tasks_view.dart';
import 'package:learn_flutter1/views/search_task_view.dart';

class MainPageView extends StatefulWidget {
  const MainPageView({Key? key}) : super(key: key);

  @override
  State<MainPageView> createState() => _MainPageViewState();
}

class _MainPageViewState extends State<MainPageView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    NoteView(),
    SearchTaskView(),
    CalendarTaskView(),
    UserView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: screenHorizontalPadding,
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0177FF),
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: 'Dismiss',
            barrierColor: Colors.black.withOpacity(0.5),
            pageBuilder: (context, _, __) {
              return const Center(child: CreateUpdateNoteView(note: null));
            },
          );
        },
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white.withOpacity(0.9),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavIcon(Icons.home, 0),
              _buildNavIcon(Icons.calendar_today, 2),
              _buildNavIcon(Icons.search, 1),
              _buildNavIcon(Icons.group, 3),
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm build icon có trạng thái selected / unselected
  Widget _buildNavIcon(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;

    return IconButton(
      onPressed: () => _onItemTapped(index),
      icon: Icon(
        icon,
        size: isSelected ? 32 : 26, // 🔹 icon được chọn to hơn
        color: isSelected ? const Color(0xFF0177FF) : Colors.grey, // 🔹 màu nổi bật
      ),
    );
  }
}
