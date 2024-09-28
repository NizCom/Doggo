import 'package:flutter/material.dart';
import 'package:mobile/common_widgets/round_gradient_button.dart';
import 'package:mobile/common_widgets/date_selector.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/services/validation_methods.dart';

class AddUpdateVaccinationScreen extends StatefulWidget {
  static const String routeName = "/AddUpdateVaccinationScreen";

  final String dogId;
  final bool isUpdate;
  final dynamic vaccination;

  const AddUpdateVaccinationScreen({
    super.key,
    required this.dogId,
    this.isUpdate = false,
    this.vaccination,
  });

  @override
  _AddUpdateVaccinationScreenState createState() => _AddUpdateVaccinationScreenState();
}

class _AddUpdateVaccinationScreenState extends State<AddUpdateVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _vaccinationTypeController = TextEditingController();
  final TextEditingController _vetNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _vaccinationDateController = TextEditingController();
  final TextEditingController _nextVaccinationController = TextEditingController();

  DateTime? _selectedVaccinationDate; // Store the selected vaccination date

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate && widget.vaccination != null) {
      _loadVaccination();
    }
  }

  @override
  void dispose() {
    _vaccinationTypeController.dispose();
    _vetNameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    _vaccinationDateController.dispose();
    _nextVaccinationController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccination() async {
    try {
      // Load vaccination details into the controllers
      _vaccinationTypeController.text = widget.vaccination['vaccination_type'] ?? '';
      _vetNameController.text = widget.vaccination['vet_name'] ?? '';
      _dosageController.text = widget.vaccination['dosage']?.toString() ?? '';
      _notesController.text = widget.vaccination['notes'] ?? '';
      _vaccinationDateController.text = widget.vaccination['vaccination_date'] ?? '';
      _nextVaccinationController.text = widget.vaccination['next_vaccination'] ?? '';

      // Initialize the selected vaccination date if updating
      if (widget.vaccination['vaccination_date'] != null) {
        _selectedVaccinationDate = DateTime.parse(widget.vaccination['vaccination_date']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vaccination: $e')),
        );
      }
    }
  }

  Future<void> _saveVaccination() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Capitalize the first letter of the vaccination type
        final vaccinationType = _vaccinationTypeController.text.isNotEmpty
            ? '${_vaccinationTypeController.text[0].toUpperCase()}${_vaccinationTypeController.text.substring(1)}'
            : '';

        final vaccinationData = {
          'vaccination_type': vaccinationType, // Use the capitalized vaccination type
          'vet_name': _vetNameController.text,
          'dosage': _dosageController.text,
          'notes': _notesController.text,
          'vaccination_date': _vaccinationDateController.text,
          'next_vaccination': _nextVaccinationController.text,
        };

        if (widget.isUpdate) {
          // Add vaccination ID to the vaccinationData
          vaccinationData['vaccination_id'] = widget.vaccination['vaccination_id'].toString(); // Ensure it's a string
          await HttpService.updateVaccination(vaccinationData);
        } else {
          // Add dog ID to the vaccinationData
          vaccinationData['dog_id'] = widget.dogId.toString(); // Ensure it's a string
          await HttpService.createNewVaccination(vaccinationData);
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving vaccination: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          widget.isUpdate ? "Update Vaccination" : "Add Vaccination",
          style: const TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _vaccinationTypeController,
                  label: 'Vaccination Type',
                  icon: Icons.vaccines,
                  validator: (value) => ValidationMethods.validateNotEmpty(value, 'Vaccination Type'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _vetNameController,
                  label: 'Vet Name',
                  icon: Icons.person,
                  validator: (value) => ValidationMethods.validateNotEmpty(value, 'Vet Name'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _dosageController,
                  label: 'Dosage (ml)',
                  icon: Icons.medication_outlined,
                  validator: (value) => ValidationMethods.validatePositiveInt(value, 'Dosage'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _notesController,
                  label: 'Notes',
                  icon: Icons.note,
                ),
                const SizedBox(height: 16),
                DateSelector(
                  dateController: _vaccinationDateController,
                  hintText: 'Vaccination Date',
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  onDateSelected: (selectedDate) {
                    setState(() {
                      _selectedVaccinationDate = selectedDate;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DateSelector(
                  dateController: _nextVaccinationController,
                  hintText: 'Next Vaccination Date',
                  initialDate: _selectedVaccinationDate ?? DateTime.now(),
                  firstDate: _selectedVaccinationDate ?? DateTime.now(), // Make sure first date is from selected vaccination date
                  lastDate: DateTime(2101),
                ),
                const SizedBox(height: 16),
                RoundGradientButton(title: widget.isUpdate ? 'Update' : 'Save', onPressed: _saveVaccination),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
    );
  }
}
