import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/utils/app_colors.dart';
import 'package:mobile/screens/map/widgets/map_view.dart';
import 'package:mobile/services/preferences_service.dart';
import 'package:mobile/screens/map/widgets/category_buttons.dart';
import 'package:mobile/screens/map/widgets/all_categories_modal.dart';
import 'package:mobile/screens/map/widgets/favorite_places_list.dart';
import 'package:mobile/services/http_service.dart';

class MapScreen extends StatefulWidget {
  static String routeName = "/MapScreen";
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  LatLng _currentPosition = const LatLng(32.0853, 34.7818); // Default position in Tel Aviv
  final List<Marker> _markers = [];
  Marker? _searchMarker;
  int? dogId;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    _loadDogId();
  }

  Future<void> _loadDogId() async {
    int? id = await PreferencesService.getDogId();
    setState(() {
      dogId = id;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    await _updateUserLocation();
  }

  Future<void> _updateUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _mapController.move(_currentPosition, 14.0);
        _updateUserMarker();
      });
    } catch (e) {
      //Error getting location
    }
  }

  void _updateUserMarker() {
    _markers.removeWhere((marker) => marker.key == const Key('userLocation'));
    _markers.add(
      Marker(
        key: const Key('userLocation'),
        point: _currentPosition,
        child: const Icon(Icons.my_location, color: AppColors.secondaryColor1, size: 20),
      ),
    );
  }

  void _handleSearch(LatLng position, String placeName) {
    setState(() {
      if (_searchMarker != null) {
        _markers.remove(_searchMarker);
      }
      _searchMarker = Marker(
        point: position,
        child: const Icon(Icons.place, color: AppColors.secondaryColor1, size: 40),
      );
      _markers.add(_searchMarker!);
      _mapController.move(position, 14.0);
    });
  }

  Future<void> _showMarkersForCategory(String category) async {
    try {
      // Fetch map markers based on the selected category
      final markersData = await HttpService.fetchMapMarkers(category);

      // Update the state with new markers
      setState(() {
        _markers.clear();
        _updateUserMarker();
        for (var markerData in markersData) {
          _markers.add(
            Marker(
              point: LatLng(markerData['place_latitude'], markerData['place_longitude']),
              child: Icon(
                Icons.location_pin,
                color: _getCategoryColor(category),
                size: 40,
              ),
            ),
          );
        }
      });
    } catch (e) {
      if(mounted) {
        // Display an error message using ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading markers: ${e.toString()}')),
        );
      }
    }
  }


  Color _getCategoryColor(String category) {
    switch (category) {
      case 'medical':
        return Colors.red;
      case 'parks':
        return Colors.green;
      case 'pensions':
        return Colors.blue;
      case 'restaurants':
        return Colors.orange;
      case 'beauty salons':
        return Colors.purple;
      case 'hotels':
        return Colors.teal;
      case 'beaches':
        return Colors.lightBlueAccent;
      case 'pet stores':
        return Colors.pink;
      default:
        return Colors.red;
    }
  }

  void _clearMarkers() {
    setState(() {
      _markers.clear();
      _updateUserMarker();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MapView(
              mapController: _mapController,
              markers: _markers,
              currentPosition: _currentPosition,
              onUpdateLocation: _updateUserLocation,
              onSearch: _handleSearch,
              onClearMarkers: _clearMarkers,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  CategoryButtons(
                    onCategorySelected: _showMarkersForCategory,
                    onMorePressed: () => _showAllCategories(context),
                  ),
                  Expanded(
                    child: dogId != null ? FavoritePlacesList(dogId: dogId!,) : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllCategories(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AllCategoriesModal(onCategorySelected: _showMarkersForCategory);
      },
    );
  }
}
