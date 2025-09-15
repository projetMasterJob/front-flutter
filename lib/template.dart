import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'list_chat.dart';
import 'menu_bottom.dart';
import 'detail_job.dart';
import 'detail_company.dart';
import 'profil.dart';

class TemplatePage extends StatefulWidget {
  final int selectedIndex;
  const TemplatePage({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  late int _selectedIndex;
  late List<Widget> _viewStack;
  DateTime? _lastBackPressed;
  
  // Pages créées une seule fois
  late final List<Widget> _pages = [
    HomeTabPage(onNavigateToDetail: _pushDetail),
    ListChat(),
    ProfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _viewStack = [];
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _viewStack = [];
    });
  }

  void _pushDetail(String type, {String? id}) {
    if (type == 'job' && id != null) {
      setState(() {
        _viewStack.add(DetailJobPage(jobId: id, onNavigateToDetail: _pushDetail, onBack: _popView));
      });
    } else if (type == 'company' && id != null) {
      setState(() {
        _viewStack.add(DetailCompanyPage(companyId: id, onNavigateToDetail: _pushDetail, onBack: _popView));
      });
    }
  }

  void _popView() {
    if (_viewStack.isNotEmpty) {
      setState(() {
        _viewStack.removeLast();
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_viewStack.length > 1) {
      setState(() {
        _viewStack.removeLast();
      });
      return false;
    }
    
    final now = DateTime.now();
    if (_lastBackPressed == null || now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliquez pour quitter'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Container(
                margin: const EdgeInsets.only(bottom: 0),
                padding: const EdgeInsets.only(bottom: 70),
                child: _viewStack.isEmpty 
                    ? IndexedStack(index: _selectedIndex, children: _pages)
                    : _viewStack.last,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MenuBottom(
                selectedIndex: _selectedIndex,
                onTabSelected: _onTabSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 