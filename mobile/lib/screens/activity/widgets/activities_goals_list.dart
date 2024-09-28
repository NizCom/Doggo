import 'package:flutter/material.dart';
import 'package:mobile/screens/activity/widgets/outdoor_activity_goal_row.dart';

class ActivitiesGoalsList extends StatelessWidget {
  final List<Map<String, dynamic>> itemsArr;
  final int? dogId;
  final String type; // "activity" or "goal" or "template"

  const ActivitiesGoalsList({
    super.key,
    required this.itemsArr,
    required this.dogId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (itemsArr.isEmpty) {
      return const Center(child: Text("No Data Available."));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemsArr.length,
      itemBuilder: (context, index) {
        var wObj = itemsArr[index];
        return InkWell(
          onTap: () {
          },
          child: OutdoorActivityGoalRow(
            item: wObj,
            dogId: dogId!,
            type: type, // Pass the type down to the OutdoorActivityRow
          ),
        );
      },
    );
  }
}
