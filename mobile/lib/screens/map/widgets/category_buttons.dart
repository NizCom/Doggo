import 'package:flutter/material.dart';

class CategoryButtons extends StatelessWidget {
  final Function(String) onCategorySelected;
  final VoidCallback onMorePressed;

  const CategoryButtons({
    super.key,
    required this.onCategorySelected,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _categoryButton('Medical', Icons.local_hospital, Colors.red),
          _categoryButton('Parks', Icons.park, Colors.green),
          _categoryButton('Restaurants', Icons.restaurant, Colors.orange),
          _moreButton(),
        ],
      ),
    );
  }

  Widget _categoryButton(String label, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: () => onCategorySelected(label.toLowerCase()),
        icon: Icon(icon, color: color),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: color, backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _moreButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        onPressed: onMorePressed,
        icon: const Icon(Icons.more_horiz, color: Colors.blue),
        label: const Text('More'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.blue, backgroundColor: Colors.white,
        ),
      ),
    );
  }
}