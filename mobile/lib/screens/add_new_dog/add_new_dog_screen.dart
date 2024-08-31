import 'package:flutter/material.dart';
import 'package:mobile/common_widgets/breed_selector.dart';
import 'package:mobile/common_widgets/gender_selector.dart';
import 'package:mobile/screens/map/set_favorite_place.dart';
import 'package:mobile/services/http_service.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../services/preferences_service.dart';
import '../../utils/app_colors.dart';
import 'package:mobile/common_widgets/date_selector.dart';

class AddNewDogScreen extends StatefulWidget {
  static String routeName = "/AddNewDogScreen";

  const AddNewDogScreen({super.key});

  @override
  _AddNewDogScreenState createState() => _AddNewDogScreenState();
}

class _AddNewDogScreenState extends State<AddNewDogScreen> {

  String? selectedBreed;
  String? selectedGender;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/images/add_your_dog.png", width: media.width),
                const SizedBox(height: 15),
                const Text(
                  "Let’s add your dog",
                  style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                const Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 25),
                RoundTextField(
                  textEditingController: _nameController,
                  hintText: "Name",
                  icon: "assets/icons/name_icon.png",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 15),
                BreedSelector(
                    selectedBreed: selectedBreed,
                    onBreedChanged: (value) {
                      setState(() {
                        selectedBreed = value;
                      });
                    }),
                const SizedBox(height: 15),
                GenderSelector(
                    selectedGender: selectedGender,
                  onGenderChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 15),
                DateSelector(birthdateController: _birthdateController),
                const SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _weightController,
                  hintText: "Weight (kg)",
                  icon: "assets/icons/weight_icon.png",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _heightController,
                  hintText: "Height (cm)",
                  icon: "assets/icons/swap_icon.png",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 15),
                RoundGradientButton(
                  title: "Next >",
                  onPressed: () async {
                    int? currUserId = await PreferencesService.getUserId();

                    // Add new dog
                    int? dogId = await HttpService.addNewDog
                      (name: _nameController.text,
                        breed: selectedBreed!,
                        gender: selectedGender!,
                        dateOfBirth: _birthdateController.text,
                        weight: double.tryParse(_weightController.text) ?? 0.0,
                        height: double.tryParse(_heightController.text) ?? 0.0,
                        userId: currUserId!);
                    if (dogId != null) {
                      // Navigate to next step
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          //builder: (context) => AddSafeZoneScreen(dogId: dogId),
                          builder: (context) => SetFavoritePlace(dogId: dogId, placeType: 'home', inCompleteRegister: true,),
                        ),
                      );
                    } else {
                      // Show SnackBar with error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to add the dog. Please try again.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
