import 'package:flutter/material.dart';

class MenuModel {
  final IconData icon;
  final String title;
  List<MenuModel>? submenus; // Mutable field for dynamic updates

  MenuModel({required this.icon, required this.title, this.submenus});
}