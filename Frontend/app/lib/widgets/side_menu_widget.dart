import 'package:flutter/material.dart';
import 'package:app/data/side_menu_data.dart';
import 'package:app/widgets/add_farm.dart';
import 'package:app/widgets/dashboard_widget.dart';
import 'package:app/const/constant.dart';

class SideMenuWidget extends StatefulWidget {
  final Function(Widget) onMenuTap;

  const SideMenuWidget({super.key, required this.onMenuTap});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  int selectedIndex = 0;
  bool isFarmsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: const Color(0xFF171821),
      child: Column(
        children: [
          // Logo
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            child: Image.asset(
              'images/logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
          // Menu items
          Expanded(
            child: ListView.builder(
              itemCount: data.menu.length,
              itemBuilder: (context, index) => buildMenuEntry(data, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index) {
    final isSelected = selectedIndex == index;
    final menuItem = data.menu[index];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        color: isSelected ? selectionColor : Colors.transparent,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
            isFarmsExpanded = menuItem.title == 'Farms' && !isFarmsExpanded;

            // Trigger the parent callback
            if (menuItem.title == 'Add Farm') {
              widget.onMenuTap(const AddFarm());
            } else if (menuItem.title == 'Farms') {
              widget.onMenuTap(const DashboardWidget());
            }
          });
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              child: Icon(
                menuItem.icon,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
            Text(
              menuItem.title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
