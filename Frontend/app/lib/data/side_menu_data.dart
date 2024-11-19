import 'package:app/models/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.add, title: 'Add Farm'),
    MenuModel(
      icon: Icons.home,
      title: 'Farms',
      submenus: [
        MenuModel(icon: Icons.agriculture, title: 'Farm 1'),
        MenuModel(icon: Icons.agriculture, title: 'Farm 2'),
        MenuModel(icon: Icons.agriculture, title: 'Farm 3'),
      ],
    ),
    MenuModel(icon: Icons.logout, title: 'SignOut'),
  ];
}
