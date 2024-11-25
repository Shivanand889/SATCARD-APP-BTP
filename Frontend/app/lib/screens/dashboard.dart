import 'package:flutter/material.dart';
import 'package:app/widgets/side_menu_widget.dart';
import 'package:app/widgets/dashboard_widget.dart';
// import 'package:app/widgets/add_farm.dart';
import 'package:app/const/constant.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Widget _selectedPage = const DashboardWidget();

  void _updatePage(Widget page) {
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: bgColor,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SideMenuWidget(
                  onMenuTap: (selectedPage) => _updatePage(selectedPage),
                ),
              ),
              Expanded(
                flex: 7,
                child: _selectedPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
