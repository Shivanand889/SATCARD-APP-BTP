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
  final hasSubmenus = menuItem.submenus != null && menuItem.submenus!.isNotEmpty;
  final isFarmsMenu = menuItem.title == 'Farms';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(6.0)),
          color: isSelected ? selectionColor : Colors.transparent,
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedIndex = index;
              if (hasSubmenus) {
                isFarmsExpanded = !isFarmsExpanded;
              } else {
                // Handle menu item without submenus
                widget.onMenuTap(_getWidgetForMenu(menuItem.title));
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
              if (hasSubmenus && isFarmsMenu)
                Icon(
                  isFarmsExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
      // Submenu rendering
      if (isFarmsExpanded && hasSubmenus && isFarmsMenu)
        ...menuItem.submenus!.map((submenu) => Padding(
              padding: const EdgeInsets.only(left: 40),
              child: InkWell(
                onTap: () {
                  // Handle submenu item tap
                  widget.onMenuTap(_getWidgetForMenu(submenu.title));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    color: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(submenu.icon, color: Colors.grey),
                      const SizedBox(width: 10),
                      Text(
                        submenu.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
    ],
  );
}


  /// Helper function to map menu titles to widgets
  Widget _getWidgetForMenu(String title) {
    switch (title) {
      case 'Add Farm':
        return const AddFarm();
      case 'Dashboard':
        return const DashboardWidget();
      case 'Farm 1':
      case 'Farm 2':
      case 'Farm 3':
        return const DashboardWidget(); // Replace with specific widgets for each submenu
      default:
        return const DashboardWidget(); // Default widget
    }
  }
}
