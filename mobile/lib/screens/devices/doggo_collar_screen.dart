import 'package:flutter/material.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class DoggoCollarScreen extends StatefulWidget {
  static String routeName = "/DoggoCollarScreen";

  const DoggoCollarScreen({super.key});

  @override
  _DoggoCollarScreenState createState() => _DoggoCollarScreenState();
}

class _DoggoCollarScreenState extends State<DoggoCollarScreen> {
  String _collarId = 'loading...';
  //late int _batteryLevel;

  @override
  void initState() {
    super.initState();
    _initializeCollarId();
    //_initializeBatteryLevel();
  }

  Future<void> _initializeCollarId() async {
    try {
      int? dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        String collarId = (await HttpService.getCollarId(dogId.toString()));
        setState(() {
          _collarId = collarId;
        });
      } else {
        print('Dog ID is null');
        setState(() {
          _collarId = 'Error retrieving collar ID';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _collarId = 'Error retrieving collar ID';
      });
    }
  }
  //
  // Future<void> _initializeBatteryLevel() async {
  //   try {
  //
  //     int? batteryLevel = await HttpService.getBatteryLevel()
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(right: 15, left: 15),
            child: Column(
              children: [
                Image.asset("assets/images/doggo_collar_background.png", width: media.width),
                const SizedBox(height: 15),
                const Text(
                  "Doggo Collar Info",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 25),
                RoundTextField(
                  hintText: _collarId.isEmpty ? "Loading..." : _collarId,
                  icon: "assets/icons/doggo_collar_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  hintText: '50%', // TODO: change to real value
                  icon: "assets/icons/battery_icon.png",
                  textInputType: TextInputType.text,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
