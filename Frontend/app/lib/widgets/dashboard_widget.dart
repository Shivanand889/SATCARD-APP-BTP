import 'package:flutter/material.dart';
import 'package:app/const/constant.dart';



 class DashboardWidget extends StatelessWidget {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Dashboard",
                  // style: Theme.of(context).textTheme.headlineSmall,
                  // selectionColor: secondaryColor,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
} 