import 'package:app/const/constant.dart';
import 'package:flutter/material.dart';

class CloudStorageInfo {
  final String? title;

  CloudStorageInfo({
    this.title,
  });
}

List<CloudStorageInfo> demoMyFiles = [
  CloudStorageInfo(
    title: "Farm Name",
  ),
  CloudStorageInfo(
    title: "Crop Name",
  ),
  CloudStorageInfo(
    title: "Land Area",
  ),
  CloudStorageInfo(
    title: "Location",
  ),
];
