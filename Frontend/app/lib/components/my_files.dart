import 'package:app/components/add_activity.dart';
import 'package:app/responsive.dart';
import 'package:app/const/constant.dart';
import 'package:flutter/material.dart';
import 'package:app/models/my_files.dart';

import 'file_info_card.dart';

class MyFiles extends StatelessWidget {
  final List<CloudStorageInfo> fileData; // Accept the data as input
  final String name ;
  const MyFiles({
    Key? key,
    required this.fileData, 
    this.name = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Farm Information",
              style: TextStyle(
                color: Colors.white,  // Change to desired color
                fontSize: 16,         // Optional: adjust font size
                fontWeight: FontWeight.w200, // Optional: set font weight
              ),
            ),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical:
                      defaultPadding / (Responsive.isMobile(context) ? 2 : 1),
                ),
              ),
              onPressed: () {
                showAddActivityDialog(context,name);
              },
              icon: Icon(Icons.add),
              label: Text("Add Activity"),
            ),
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            fileData: fileData, // Pass the data to the grid view
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 ? 1.3 : 1,
          ),
          tablet: FileInfoCardGridView(fileData: fileData),
          desktop: FileInfoCardGridView(
            fileData: fileData,
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  final List<CloudStorageInfo> fileData; // Accept the data here
  final int crossAxisCount;
  final double childAspectRatio;

  const FileInfoCardGridView({
    Key? key,
    required this.fileData, // Mark as required
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: fileData.length, // Use the provided data length
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: defaultPadding,
        mainAxisSpacing: defaultPadding,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => FileInfoCard(info: fileData[index]),
    );
  }
}
