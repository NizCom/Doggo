import 'package:mobile/screens/activity/widgets/activities_goals_list.dart';
import 'package:mobile/screens/home/widgets/BCS_pie_chart.dart';
import 'package:mobile/screens/home/widgets/dog_activity_status.dart';
import 'package:mobile/services/ble_service.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/main.dart';
import '../../common_widgets/round_button.dart';
import '../activity/activities_goals_history.dart';
import '../activity/start_new_activity.dart';
import '../activity/widgets/activity_circles_widget.dart';
import '../devices/BLE_connection_screen.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  final BleService _bleService = BleService();
  bool _isConnectedToBle = false;
  String? _dogName;
  int? dogId;
  late List<Map<String, dynamic>> activitiesArr = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _checkBleConnectionStatus();
    _fetchDogInfo();
    _fetchDog3LatestActivities();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _initialize() {
    _checkBleConnectionStatus();
    _fetchDogInfo();
    _fetchDog3LatestActivities();
  }

  void _checkBleConnectionStatus() async {
    final isConnected = await _bleService.isConnected;
    setState(() {
      _isConnectedToBle = isConnected;
    });
  }

  void _fetchDogInfo() async {
    try {
      // Fetch dogId from preferences
      dogId = await PreferencesService.getDogId();

      if (dogId != null) {
        // Try fetching dog information
        final dogInfo = await HttpService.getDogInfo(dogId!);
        final dogName = dogInfo['name'];

        // Update UI with dog name
        setState(() {
          _dogName = dogName;
        });
      }
    } catch (e) {
      // Handle any errors and display a SnackBar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch dog info: ${e.toString()}')),
      );
    }
  }


  void _fetchDog3LatestActivities() async {
    try {
      final dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        final activities = await HttpService.getOutdoorActivities(dogId, 3, 0); // request for the latest 3 activities
        if (activities != null) {
          setState(() {
            activitiesArr = activities;
          });
        }
      }
    } catch (e) {
      print('Error fetching activities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching activities. Please try again later.')),
      );
    }
  }


  void _showActivityCirclesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 300.0,
            height: 180.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.primaryG, // Assuming AppColors.primaryG is a List<Color>
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0), // Optional: rounded corners
            ),
            child: Center(
              child: ActivityCirclesWidget(
                onActivitySelected: (String activityType) {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StartNewActivityScreen(
                        activityType: activityType,
                        dogId: dogId!,
                        currentActivityId: null, // No current activity in progress
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }


  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
    FlSpot(0, 20),
    FlSpot(1, 25),
    FlSpot(2, 40),
    FlSpot(3, 50),
    FlSpot(4, 35),
    FlSpot(5, 40),
    FlSpot(6, 30),
    FlSpot(7, 20),
    FlSpot(8, 25),
    FlSpot(9, 40),
    FlSpot(10, 50),
    FlSpot(11, 35),
    FlSpot(12, 50),
    FlSpot(13, 60),
    FlSpot(14, 40),
    FlSpot(15, 50),
    FlSpot(16, 20),
    FlSpot(17, 25),
    FlSpot(18, 40),
    FlSpot(19, 50),
    FlSpot(20, 35),
    FlSpot(21, 80),
    FlSpot(22, 30),
    FlSpot(23, 20),
    FlSpot(24, 25),
    FlSpot(25, 40),
    FlSpot(26, 50),
    FlSpot(27, 35),
    FlSpot(28, 50),
    FlSpot(29, 60),
    FlSpot(30, 40),
  ];

  List<LineChartBarData> get lineBarsData1 => [
    lineChartBarData1_1,
    lineChartBarData1_2,
  ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
    isCurved: true,
    gradient: LinearGradient(colors: [
      AppColors.primaryColor2.withOpacity(0.5),
      AppColors.primaryColor1.withOpacity(0.5),
    ]),
    barWidth: 4,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(show: false),
    spots: const [
      FlSpot(1, 35),
      FlSpot(2, 70),
      FlSpot(3, 40),
      FlSpot(4, 80),
      FlSpot(5, 25),
      FlSpot(6, 70),
      FlSpot(7, 35),
    ],
  );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
    isCurved: true,
    gradient: LinearGradient(colors: [
      AppColors.secondaryColor2.withOpacity(0.5),
      AppColors.secondaryColor1.withOpacity(0.5),
    ]),
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(show: false),
    belowBarData: BarAreaData(
      show: false,
    ),
    spots: const [
      FlSpot(1, 80),
      FlSpot(2, 50),
      FlSpot(3, 90),
      FlSpot(4, 40),
      FlSpot(5, 80),
      FlSpot(6, 35),
      FlSpot(7, 60),
    ],
  );

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: false,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            AppColors.primaryColor2.withOpacity(0.4),
            AppColors.primaryColor1.withOpacity(0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: AppColors.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.bluetooth,
                  color: _isConnectedToBle ? Colors.green : Colors.red,),
                color: AppColors.blackColor,
                onPressed: () async {
                  await Navigator.pushNamed(context, BleConnectionScreen.routeName);
                  _checkBleConnectionStatus();
                },
              ),
            ],
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isConnectedToBle ?
            const Icon(
              Icons.phone,
              color: AppColors.blackColor,
              size: 20,
            ) :
            const Icon(
              Icons.home,
              color: AppColors.blackColor,
              size: 20,
            ) ,
            SizedBox(width: 8),
            Text(
              _dogName ?? 'Dog Name',
              style: const TextStyle(
                color: AppColors.blackColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8), // Space between the icon and the title
            Icon(Icons.battery_3_bar), // TODO: change by battery level
            const SizedBox(width: 50,)
          ],
        ),
        // actions: [
        //   InkWell(
        //       onTap: () {
        //         // Navigator.pushNamed(context, NotificationScreen.routeName);
        //       },
        //       // child: IconButton(
        //       //   icon: Image.asset(
        //       //     "assets/icons/notification_icon.png",
        //       //     width: 24, // Set width here
        //       //     height: 24, // Set height here
        //       //     fit: BoxFit.contain,
        //       //   ),
        //       //   onPressed: () {
        //       //     // Navigator.pushNamed(context, NotificationsScreen.routeName);
        //       //   },
        //       // )
        //   ),],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DogActivityStatus(),
                SizedBox(height: media.width * 0.05),
                const Divider(),
                SizedBox(height: media.width * 0.0005),
                RoundButton(
                    title: "Add New Activity",
                    onPressed: () {
                      _showActivityCirclesDialog(context);
                    },
                    backgroundColor: AppColors.primaryColor2,
                    titleColor: AppColors.whiteColor),
                const Divider(),
                SizedBox(height: media.width * 0.05),
                BcsPieChart(dogId: dogId!,),
                SizedBox(height: media.width * 0.05),
                // WorkoutProgressLineChart(),
                // SizedBox(
                //   height: media.width * 0.05,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Latest Outdoor Activities",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.open_in_new),
                      color: AppColors.primaryColor1,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ActivitiesGoalsHistoryScreen(dogId: dogId!, type: 'activity',),
                          ),
                        );
                      },
                      tooltip: 'Open Activities History',
                    ),
                  ],
                ),
                ActivitiesGoalsList(ItemsArr: activitiesArr, dogId: dogId, type: 'activity',),
                SizedBox(
                  height: media.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}