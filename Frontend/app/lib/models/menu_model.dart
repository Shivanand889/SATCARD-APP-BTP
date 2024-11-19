import 'package:flutter/material.dart';

class MenuModel {
  final IconData icon;
  final String title;
  final List<MenuModel>? submenus; // Add submenus

  const MenuModel({
    required this.icon,
    required this.title,
    this.submenus,
  });
}
