
import 'package:app/const/constant.dart';
import 'package:flutter/material.dart';
import 'chart.dart';
import 'storage_info_card.dart';

class StorageDetails extends StatelessWidget {
  final Map<String, dynamic> weatherData; // Accept weather data as input

  const StorageDetails({
    Key? key,
    required this.weatherData, // Make it required to pass the data
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weather Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: defaultPadding),
          // Chart or any weather data visualization can go here
          StorageInfoCard(
            svgSrc: "icons/temperature.svg",
            title: "Temperature",
            amountOfFiles: "${weatherData['temperature']}°C", // Display dynamic temperature value
          ),
          StorageInfoCard(
            svgSrc: "icons/humidity.svg",
            title: "Humidity",
            amountOfFiles: "${weatherData['humidity']}%", // Display dynamic humidity value
          ),
          StorageInfoCard(
            svgSrc: "icons/wind.svg",
            title: "Wind",
            amountOfFiles: "${weatherData['wind']} m/s", // Display dynamic wind value
          ),
          StorageInfoCard(
            svgSrc: "icons/rain.svg",
            title: "Precipitation",
            amountOfFiles: "${weatherData['precipitation']}%", // Display dynamic precipitation value
          ),
        ],
      ),
    );
  }
}
