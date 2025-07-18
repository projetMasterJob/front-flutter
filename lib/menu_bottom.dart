import 'package:flutter/material.dart';

class MenuBottom extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  const MenuBottom({Key? key, required this.selectedIndex, required this.onTabSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildMenuButton(context, Icons.search, 0, selectedIndex == 0),
          _buildMenuButton(context, Icons.chat_bubble_outline, 1, selectedIndex == 1),
          _buildMenuButton(context, Icons.person_outline, 2, selectedIndex == 2),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, int index, bool selected) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => onTabSelected(index),
          child: Center(
            child: Icon(
              icon,
              size: 28,
              color: selected ? Colors.blue : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
