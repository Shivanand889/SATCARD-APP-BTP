
import 'package:app/const/constant.dart';
import 'package:flutter/material.dart';
import 'chart.dart';
import 'storage_info_card.dart';

class StorageDetails extends StatelessWidget {
  const StorageDetails({
    Key? key,
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
          Chart(),
          StorageInfoCard(
            svgSrc: "icons/temperature.svg",
            title: "Temperature",
            amountOfFiles: "30°C",
          ),
          StorageInfoCard(
            svgSrc: "icons/humidity.svg",
            title: "Humidity",
            amountOfFiles: "91%",
          ),
          StorageInfoCard(
            svgSrc: "icons/wind.svg",
            title: "Wind",
            amountOfFiles: "6 km/h",
          ),
          StorageInfoCard(
            svgSrc: "icons/rain.svg",
            title: "Precipitation",
            amountOfFiles: "25%",
          ),
        ],
      ),
    );
  }
}
