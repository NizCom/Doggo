import 'package:flutter/material.dart';
import 'package:mobile/services/http_service.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/utils/app_colors.dart';
import 'add_update_vaccination_screen.dart';

class VaccinationsScreen extends StatefulWidget {
  static const String routeName = "/VaccinationsScreen";

  const VaccinationsScreen({super.key});

  @override
  _VaccinationsScreenState createState() => _VaccinationsScreenState();
}

class _VaccinationsScreenState extends State<VaccinationsScreen> {
  List<dynamic>? vaccinations = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String selectedType = "all";
  List<String> vaccinationTypes = [
    "all", "Distemper", "Rabies", "Parvo", "Leptospirosis", "Hepatitis", "Bordetella", "Parainfluenza"
  ];
  int? dogId;
  int limit = 5;
  int offset = 0;
  bool hasMoreVaccinations = true;

  @override
  void initState() {
    super.initState();
    fetchVaccinations();
  }

  Future<void> fetchVaccinations({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        setState(() {
          isLoading = true;
          offset = 0;
          vaccinations = [];
          hasMoreVaccinations = true;
        });
      } else {
        setState(() {
          isLoadingMore = true;
        });
      }

      dogId = await PreferencesService.getDogId();
      if (dogId != null) {
        final newVaccinations = await HttpService.getVaccinationsByType(dogId!, selectedType, limit, offset);

        setState(() {
          if (loadMore) {
            vaccinations = [...?vaccinations, ...?newVaccinations];
          } else {
            vaccinations = newVaccinations ?? [];
          }
          isLoading = false;
          isLoadingMore = false;
          offset += limit;

          hasMoreVaccinations = (newVaccinations?.length ?? 0) >= limit;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
        hasMoreVaccinations = false;
      });
    }
  }

  void _onTypeChanged(String? value) {
    setState(() {
      selectedType = value!;
    });
    fetchVaccinations();
  }

  Future<void> deleteVaccination(int vaccinationId) async {
    try {
      await HttpService.deleteVaccination(vaccinationId);
      fetchVaccinations();
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Vaccinations",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.whiteColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green,),
            onPressed: () async {
              // Navigate to the AddUpdateVaccinationScreen for adding a new vaccination
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddUpdateVaccinationScreen(
                    dogId: dogId!.toString(),
                    isUpdate: false,
                  ),
                ),
              );

              if (result == true) {
                fetchVaccinations();
              }
            },
            color: AppColors.blackColor,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor2))
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedType,
                dropdownColor: AppColors.whiteColor,
                onChanged: _onTypeChanged,
                items: vaccinationTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: const TextStyle(color: AppColors.blackColor),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: vaccinations!.isEmpty
                  ? const Center(
                child: Text(
                  "No vaccinations found.",
                  style: TextStyle(color: AppColors.blackColor),
                ),
              )
                  : ListView.builder(
                itemCount: vaccinations?.length ?? 0,
                itemBuilder: (context, index) {
                  final vaccination = vaccinations?[index];
                  if (vaccination == null) return Container();

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    color: AppColors.lightGrayColor,
                    child: ListTile(
                      title: Text(
                        vaccination['vaccination_type'] ?? 'Unknown',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackColor,
                        ),
                      ),
                      subtitle: Text(
                        'Date: ${vaccination['vaccination_date'] ?? 'N/A'}, Vet: ${vaccination['vet_name'] ?? 'N/A'}',
                        style: const TextStyle(color: AppColors.grayColor),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              // Navigate to the AddUpdateVaccinationScreen for editing an existing vaccination
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddUpdateVaccinationScreen(
                                    dogId: dogId!.toString(),
                                    isUpdate: true,
                                    vaccination: vaccination,
                                  ),
                                ),
                              );

                              if (result == true) {
                                fetchVaccinations();
                              }
                            },
                            color: AppColors.primaryColor1,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteVaccination(vaccination['vaccination_id']),
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: CircularProgressIndicator(color: AppColors.primaryColor2),
              ),
            if (!isLoadingMore && hasMoreVaccinations)
              ElevatedButton(
                onPressed: () => fetchVaccinations(loadMore: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor1,
                  foregroundColor: AppColors.blackColor,
                ),
                child: const Text('Load More', style: TextStyle(color: AppColors.blackColor)),
              ),
          ],
        ),
      ),
    );
  }


}