import 'package:flutter/material.dart';
import 'home_map.dart';
import 'home_list.dart';

enum ListSortOption {
  nameAZ,
  nameZA,
  distanceAsc,
  distanceDesc,
}

class HomeTabPage extends StatefulWidget {
  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  int _selectedIndex = 0;
  String _search = '';
  final TextEditingController _searchController = TextEditingController();
  ListSortOption _sort = ListSortOption.nameAZ;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortModal() async {
    final result = await showModalBottomSheet<ListSortOption>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18, left: 18, right: 12, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Trier la liste',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, color: Colors.grey[700], size: 24),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Nom A-Z', style: TextStyle(color: _sort == ListSortOption.nameAZ ? Color(0xFF3264E0) : null)),
                onTap: () => Navigator.pop(context, ListSortOption.nameAZ),
                selected: _sort == ListSortOption.nameAZ,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 1,
                margin: EdgeInsets.symmetric(vertical: 6),
                color: Colors.grey[300],
              ),
              ListTile(
                title: Text('Nom Z-A', style: TextStyle(color: _sort == ListSortOption.nameZA ? Color(0xFF3264E0) : null)),
                onTap: () => Navigator.pop(context, ListSortOption.nameZA),
                selected: _sort == ListSortOption.nameZA,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 1,
                margin: EdgeInsets.symmetric(vertical: 6),
                color: Colors.grey[300],
              ),
              ListTile(
                title: Text('Distance croissante', style: TextStyle(color: _sort == ListSortOption.distanceAsc ? Color(0xFF3264E0) : null)),
                onTap: () => Navigator.pop(context, ListSortOption.distanceAsc),
                selected: _sort == ListSortOption.distanceAsc,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 1,
                margin: EdgeInsets.symmetric(vertical: 6),
                color: Colors.grey[300],
              ),
              ListTile(
                title: Text('Distance décroissante', style: TextStyle(color: _sort == ListSortOption.distanceDesc ? Color(0xFF3264E0) : null)),
                onTap: () => Navigator.pop(context, ListSortOption.distanceDesc),
                selected: _sort == ListSortOption.distanceDesc,
              ),
            ],
          ),
        );
      },
    );
    if (result != null && result != _sort) {
      setState(() {
        _sort = result;
      });
    }
  }

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
                        controller: _searchController,
                        onChanged: (v) => setState(() => _search = v),
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    if (_selectedIndex == 1) // Onglet Liste
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Icon(Icons.tune, color: Colors.grey[600]),
                          onPressed: _showSortModal,
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
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  HomeMapPage(
                    search: _search,
                    onClearSearch: () {
                      setState(() {
                        _search = '';
                        _searchController.clear();
                      });
                    },
                  ),
                  HomeListPage(search: _search, sort: _sort),
                ],
              ),
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