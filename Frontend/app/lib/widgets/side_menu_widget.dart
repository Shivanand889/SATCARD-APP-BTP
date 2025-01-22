import 'dart:convert'; // For JSON decoding
import 'package:app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:app/data/side_menu_data.dart';
import 'package:app/models/menu_model.dart';
import 'package:app/models/my_files.dart';
import 'package:app/widgets/add_farm.dart';
import 'package:app/widgets/dashboard_widget.dart';
import 'package:app/widgets/main_dashboard.dart';
import 'package:app/const/constant.dart';

class SideMenuWidget extends StatefulWidget {
  final Function(Widget) onMenuTap;

  const SideMenuWidget({super.key, required this.onMenuTap});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  int selectedIndex = 0;
  bool isFarmsExpanded = false;
  late SideMenuData data; // Declare SideMenuData as a member variable
  bool isFarmsDataFetched = false; // Track if the farm data has been fetched

  @override
  void initState() {
    super.initState();
    data = SideMenuData(); // Initialize it here
  }

  Future<void> fetchFarmData() async {
    const url = 'http://127.0.0.1:8000/farmList'; // Replace with actual API URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Parse the response body to get the farm names
        final responseData = jsonDecode(response.body);  // Decoding the JSON response
        final farms = responseData['farms'] as List<dynamic>;

        // Convert the farms into MenuModel items
        final farmMenuItems = farms
            .map((farm) => MenuModel(icon: Icons.agriculture, title: farm))
            .toList();

        print(farmMenuItems);  // This will print the list of farm menu items

        setState(() {
          data.updateFarms(farmMenuItems); // Update farms in the side menu data
          isFarmsDataFetched = true; // Set the flag to true once data is fetched
        });
      } else {
        throw Exception('Failed to fetch farms');
      }
    } catch (e) {
      // Handle error
      print('Error fetching farms: $e');
    }
  }

 Future<Map<String, dynamic>>  fetchFarmRelatedData(String farmName) async {
  const url = 'http://127.0.0.1:8000/farmData'; // Replace with actual API URL
  try {
    // Append farm name to the API endpoint or pass as query parameters
    final response = await http.get(Uri.parse('$url?farmName=$farmName'));

    if (response.statusCode == 200) {
      // Parse the response body to get the farm data
      final responseData = jsonDecode(response.body);
      final farmData = responseData['farm']; // Assume your backend returns farm data

      print(farmData); // Print farm data for debugging

      setState(() {
        demoMyFiles[0] = CloudStorageInfo(title: farmData['name']);
        demoMyFiles[1] = CloudStorageInfo(title: farmData['crop_name']);
        demoMyFiles[2] = CloudStorageInfo(title: farmData['land_area']);
        demoMyFiles[3] = CloudStorageInfo(title: farmData['location']);
      });

      // Return weather data (assuming it's part of the response)
      return {
        'weather': responseData['weather'],  // Weather data from the response
        'activity': responseData['activity'], // Activity data from the response
      };
    } else {
      throw Exception('Failed to fetch farm data for $farmName');
    }
  } catch (e) {
    print('Error fetching farm data: $e');
    return {}; // Return an empty map in case of an error
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      color: const Color(0xFF171821),
      child: Column(
        children: [
          // Logo
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            child: Image.asset(
              'images/logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
          // Menu items
          Expanded(
            child: ListView.builder(
              itemCount: data.menu.length,
              itemBuilder: (context, index) => buildMenuEntry(data, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index) {
    final isSelected = selectedIndex == index;
    final menuItem = data.menu[index];
    final hasSubmenus = menuItem.submenus != null && menuItem.submenus!.isNotEmpty;
    final isFarmsMenu = menuItem.title == 'Farms';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
            color: isSelected ? selectionColor : Colors.transparent,
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedIndex = index;
                if (isFarmsMenu) {
                  // Only fetch farm data if it's not already fetched
                  fetchFarmData();

                  isFarmsExpanded = !isFarmsExpanded;
                } else {
                  // Handle menu item without submenus
                  widget.onMenuTap(_getWidgetForMenu(menuItem.title));
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                      child: Icon(
                        menuItem.icon,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    Text(
                      menuItem.title,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected ? Colors.black : Colors.grey,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (hasSubmenus && isFarmsMenu)
                  Icon(
                    isFarmsExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
        // Submenu rendering
        if (isFarmsExpanded && hasSubmenus && isFarmsMenu)
          ...menuItem.submenus!.map((submenu) => Padding(
                padding: const EdgeInsets.only(left: 40),
                child: InkWell(
                  onTap: () {
                    // Handle submenu item tap
                    widget.onMenuTap(_getWidgetForMenu(submenu.title));
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      color: Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Icon(submenu.icon, color: Colors.grey),
                        const SizedBox(width: 10),
                        Text(
                          submenu.title,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  /// Helper function to map menu titles to widgets
  Widget _getWidgetForMenu(String title) {
  switch (title) {
    case 'Add Farm':
      return const AddFarm();
    case 'Dashboard':
      return MainDashboard(); 

    case 'SignOut': 
       return WelcomeScreen();
        
    default:
      return FutureBuilder<Map<String, dynamic>>(
        future: fetchFarmRelatedData(title), // Call async method here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final weatherData = snapshot.data!['weather'];  // Extract weather data
            final activityData = snapshot.data!['activity'];  // Extract activity data
            
            return DashboardWidget(
              farmData: demoMyFiles, 
              weatherData: weatherData, 
              activityData: activityData,  // Pass the activity data here
              name: title,
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      );
  }
}

}
