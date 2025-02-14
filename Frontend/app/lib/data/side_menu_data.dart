import 'package:app/models/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = <MenuModel>[
    MenuModel(icon: Icons.home, title: 'Dashboard'),
    MenuModel(icon: Icons.add, title: 'Add Farm'),
    MenuModel(
      icon: Icons.home,
      title: 'Farms',
      submenus: [MenuModel(icon: Icons.agriculture, title: 'Farm 4'),
        MenuModel(icon: Icons.agriculture, title: 'Farm 1'),], // Initially empty, can be updated dynamically
    ),
    MenuModel(icon: Icons.support, title: 'Raise Ticket'),
    MenuModel(icon: Icons.logout, title: 'SignOut'),
  ];

  void updateFarms(List<MenuModel> farms) {
    for (var item in menu) {
      if (item.title == 'Farms') {
        item.submenus = farms; // Update the submenus dynamically
        break;
      }
    }
  }
}

