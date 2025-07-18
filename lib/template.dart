import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'list_chat.dart';
import 'menu_bottom.dart';
import 'detail_job.dart';
import 'detail_company.dart';

class TemplatePage extends StatefulWidget {
  final int selectedIndex;
  const TemplatePage({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  late int _selectedIndex;
  late Widget _currentView;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
    _currentView = _getBody(_selectedIndex);
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return HomeTabPage(onNavigateToDetail: _replaceWithDetail);
      case 1:
        return ListChat();
      case 2:
        return Center(child: Text('Profil (à implémenter)', style: TextStyle(fontSize: 20)));
      default:
        return Container();
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _currentView = _getBody(index);
    });
  }

  void _replaceWithDetail(String type, {String? id}) {
    setState(() {
      if (type == 'job' && id != null) {
        _currentView = DetailJobPage(jobId: id);
      } else if (type == 'company' && id != null) {
        _currentView = DetailCompanyPage(companyId: id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _currentView),
      bottomNavigationBar: MenuBottom(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
} 