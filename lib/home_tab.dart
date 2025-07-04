import 'package:flutter/material.dart';
import 'home_map.dart';
import 'home_list.dart';

class HomeTabPage extends StatefulWidget {
  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [HomeMapPage(), HomeListPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.search, color: Colors.grey[500]),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  _TabButton(
                    label: 'Carte',
                    selected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _TabButton(
                    label: 'Liste',
                    selected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          child: Stack(
            children: [
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selected ? Color(0xFF3264E0) : Colors.grey[600],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: selected
                    ? Container(
                        height: 3,
                        width: double.infinity,
                        color: Color(0xFF7EC8E3), // bleu clair
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 