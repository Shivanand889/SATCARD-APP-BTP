import 'package:app/data/side_menu_data.dart';
import 'package:flutter/material.dart';
import 'package:app/const/constant.dart';

class SideMenuWidget extends StatefulWidget {
  const SideMenuWidget({super.key});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  int selectedIndex = 0;
  bool isFarmsExpanded = false; // Track the expansion state of "Farms"

  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: const Color(0xFF171821),
      child: ListView.builder(
        itemCount: data.menu.length,
        itemBuilder: (context, index) => buildMenuEntry(data, index),
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index) {
    final isSelected = selectedIndex == index;
    final menuItem = data.menu[index];

    // Check if the item has submenus (for dropdown behavior)
    if (menuItem.submenus != null && menuItem.title == 'Farms') {
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
                  isFarmsExpanded = !isFarmsExpanded; // Toggle dropdown
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
                  Spacer(),
                  Icon(
                    isFarmsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: isSelected ? Colors.black : Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          // Display submenus if "Farms" is expanded
          if (isFarmsExpanded)
            ...menuItem.submenus!.map((submenu) => Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), // indent submenus
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                color: Colors.transparent,
              ),
              child: InkWell(
                onTap: () {
                  // Handle submenu item tap
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      child: Icon(
                        submenu.icon,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                    Text(
                      submenu.title,
                      style: const TextStyle(
                        fontSize: 14, // Submenu font size
                        color: Colors.grey, // Submenu font color
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            )),
        ],
      );
    }

    // Default menu entry for items without submenus
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        color: isSelected ? selectionColor : Colors.transparent,
      ),
      child: InkWell(
        onTap: () => setState(() {
          selectedIndex = index;
          isFarmsExpanded = false; // Collapse "Farms" when other item is selected
        }),
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
