import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common_widgets/breed_selector.dart';
import 'package:mobile/common_widgets/date_selector.dart';
import 'package:mobile/common_widgets/gender_selector.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/services/validation_methods.dart';
import 'package:mobile/common_widgets/round_textfield.dart';
import 'package:mobile/utils/app_colors.dart';

class DogDataScreen extends StatefulWidget {
  static const String routeName = "/DogDataScreen";

  final bool editMode;

  const DogDataScreen({super.key, this.editMode = false});

  @override
  _DogDataScreenState createState() => _DogDataScreenState();
}

class _DogDataScreenState extends State<DogDataScreen> {
  late bool _isEditing;
  String _dogName = 'Loading...';
  String _dogBreed = 'Loading...';
  String _dogGender = 'Loading...';
  DateTime? _dogDateOfBirth;
  String _dogHeight = 'Loading...';
  String _dogWeight = 'Loading...';
  String _dogDescription = 'Loading...';

  String? _nameError;
  String? _breedError;
  String? _genderError;
  String? _dateOfBirthError;
  String? _heightError;
  String? _weightError;
  String? _descriptionError;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedGender;
  String? _selectedBreed;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editMode; // Initialize _isEditing based on the editMode parameter
    _fetchDogData();
  }

  Future<void> _fetchDogData() async {
    try {
      final int? dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        final dogInfo = await HttpService.getDogInfo(dogId);

        setState(() {
          _dogName = dogInfo['name'];
          _dogBreed = dogInfo['breed'];
          _selectedBreed = _dogBreed;
          _dogGender = dogInfo['gender'];
          _selectedGender = _dogGender;
          _dogDateOfBirth = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
              .parse(dogInfo['date_of_birth'], true)
              .toLocal();
          _dogHeight = '${dogInfo['height']} cm';
          _dogWeight = '${dogInfo['weight']} kg';
          _dogWeight = '${dogInfo['weight']} kg';
          _dogDescription = dogInfo['description'];

          _nameController.text = _dogName;
          _breedController.text = _dogBreed;
          _genderController.text = _dogGender;
          _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(_dogDateOfBirth!);
          _weightController.text = dogInfo['weight'].toString();
          _heightController.text = dogInfo['height'].toString();
          _descriptionController.text = _dogDescription;
        });
      }
    } catch (e) {
      setState(() {
        _dogName = 'Error loading data';
        _dogBreed = 'Error loading data';
        _dogGender = 'Error loading data';
        _dogDateOfBirth = null;
        _dogHeight = 'Error loading data';
        _dogWeight = 'Error loading data';
        _dogDescription = 'Error loading data';
      });
    }
  }

  Future<void> _saveDogProfile() async {
    setState(() {
      _nameError = ValidationMethods.validateNotEmpty(_nameController.text, 'Name');
      _breedError = _validateBreed(_selectedBreed);
      _genderError = _validateGender(_selectedGender);
      _dateOfBirthError = ValidationMethods.validateNotEmpty(_dateOfBirthController.text, 'Date of birth');
      _heightError = ValidationMethods.validatePositiveInt(_heightController.text, 'Height');
      _weightError = ValidationMethods.validatePositiveDouble(_weightController.text, 'Weight');
      _descriptionError = ValidationMethods.validateNotEmpty(_descriptionController.text, 'Description');
    });

    if (_nameError != null || _breedError != null || _genderError != null ||
        _dateOfBirthError != null || _heightError != null || _weightError != null || _descriptionError != null) {
      return;
    }

    try {
      final int? dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        await HttpService.updateDogProfile(
            dogId,
            _nameController.text,
            _selectedBreed!,
            _selectedGender!,
            DateFormat('yyyy-MM-dd').parse(_dateOfBirthController.text).toString(),
            double.parse(_weightController.text),
            int.parse(_heightController.text),
            _descriptionController.text
        );
        await _fetchDogData();
        setState(() {
          _isEditing = false;
          _nameError = null;
          _breedError = null;
          _genderError = null;
          _dateOfBirthError = null;
          _heightError = null;
          _weightError = null;
          _descriptionError = null;
        });
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Dog profile updated successfully")),
          );
        }
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update dog profile: ${e.toString()}")),
        );
      }
    }
  }

  String? _validateBreed(String? value) {
    if (value == null || value.isEmpty) {
      return 'Breed cannot be empty';
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender cannot be empty';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveDogProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/dog_profile.png",
                  width: media.width * 0.3,
                ),
                const SizedBox(height: 5),
                const Text(
                  "Dog Profile Info",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                RoundTextField(
                  title: "Name",
                  textEditingController: _nameController,
                  hintText: _dogName.isEmpty ? "Loading..." : _dogName,
                  icon: "assets/icons/name_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: !_isEditing,
                  errorText: _nameError,
                ),
                const SizedBox(height: 10),
                _isEditing
                    ? BreedSelector(
                  selectedBreed: _selectedBreed,
                  onBreedChanged: (breed) {
                    setState(() {
                      _selectedBreed = breed;
                    });
                  },
                )
                    : RoundTextField(
                  title: "Breed",
                  textEditingController: _breedController,
                  hintText: _dogBreed.isEmpty ? "Loading..." : _dogBreed,
                  icon: "assets/icons/breed_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: true,
                  errorText: _breedError,
                ),
                const SizedBox(height: 10),
                _isEditing
                    ? GenderSelector(
                  selectedGender: _selectedGender,
                  onGenderChanged: (gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                )
                    : RoundTextField(
                  title: "Gender",
                  textEditingController: _genderController,
                  hintText: _dogGender.isEmpty ? "Loading..." : _dogGender,
                  icon: "assets/icons/gender_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: true,
                  errorText: _genderError,
                ),
                const SizedBox(height: 10),
                _isEditing?
                DateSelector(
                  dateController: _dateOfBirthController,
                  hintText: "Date of Birth",
                  initialDate: _dogDateOfBirth ?? DateTime(2000, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                ) :
                RoundTextField(
                  title: "Date of Birth",
                  hintText: _dogDateOfBirth == null ? "Error retrieving date of birth" : _dogDateOfBirth.toString(),
                  icon: "assets/icons/date_icon.png",
                  textInputType: TextInputType.datetime,
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                RoundTextField(
                  title: "Weight",
                  textEditingController: _weightController,
                  hintText: _dogWeight.isEmpty ? "Loading..." : _dogWeight,
                  icon: "assets/icons/weight_icon.png",
                  textInputType: TextInputType.number,
                  readOnly: !_isEditing,
                  errorText: _weightError,
                ),
                const SizedBox(height: 10),
                RoundTextField(
                  title: "Height",
                  textEditingController: _heightController,
                  hintText: _dogHeight.isEmpty ? "Loading..." : _dogHeight,
                  icon: "assets/icons/swap_icon.png",
                  textInputType: TextInputType.number,
                  readOnly: !_isEditing,
                  errorText: _heightError,
                ),
                const SizedBox(height: 10),
                RoundTextField(
                  title: "Description",
                  textEditingController: _descriptionController,
                  hintText: _dogDescription.isEmpty ? "Loading..." : _dogDescription,
                  icon: "assets/icons/notes_icon.png",
                  textInputType: TextInputType.text,
                  readOnly: !_isEditing,
                  errorText: _descriptionError,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
