import 'package:app/widgets/side_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:app/const/constant.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        // brightness: Brightness.dark,
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  child: SideMenuWidget(),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
