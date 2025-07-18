import 'package:flutter/material.dart';

class MenuBottom extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;
  const MenuBottom({Key? key, required this.selectedIndex, required this.onTabSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
          _buildMenuButton(context, Icons.search, 0, selectedIndex == 0, 'Carte'),
          _buildMenuButton(context, Icons.chat_bubble_outline, 1, selectedIndex == 1, 'Messages'),
          _buildMenuButton(context, Icons.person_outline, 2, selectedIndex == 2, 'Profil'),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, int index, bool selected, String label) {
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? Colors.blue : Colors.black,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.blue : Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
