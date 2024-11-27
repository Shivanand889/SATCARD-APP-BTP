import 'package:app/components/header.dart';
import 'package:app/components/my_files.dart';
import 'package:app/components/recent_files.dart';
import 'package:app/components/storage_details.dart';
import 'package:app/responsive.dart';
import 'package:flutter/material.dart';
import 'package:app/const/constant.dart';
import 'package:app/models/my_files.dart';

class DashboardWidget extends StatelessWidget {
  final List<CloudStorageInfo> farmData; // Accept farm data as input
  final Map<String, dynamic> weatherData; // Accept weather data as input
  final String name ;
  final List<dynamic> activityData;

  const DashboardWidget({
    super.key,
    this.farmData = const [], // Optional farm data parameter with a default empty list
    this.weatherData = const {}, // Optional weather data parameter with a default empty map
    this.name = "" ,
    this.activityData= const [],
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(),
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      MyFiles(fileData: farmData , name : name), // Pass the farm data to MyFiles
                      SizedBox(height: defaultPadding),
                      RecentFiles(activityData : activityData),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                      if (Responsive.isMobile(context)) StorageDetails(weatherData: weatherData), // Pass weatherData
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: StorageDetails(weatherData: weatherData), // Pass weatherData
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
