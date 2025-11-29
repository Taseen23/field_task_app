import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';

class LocationController extends GetxController {
  final logger = Logger();

  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool isLocationEnabled = RxBool(false);
  final RxBool isLoading = RxBool(false);
  final RxString errorMessage = RxString('');

  static const double proximityRadius = 100.0; // 100 meters

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        errorMessage.value = 'Location services are disabled.';
        isLocationEnabled.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value =
            'Location permissions are permanently denied. Please enable them in settings.';
        isLocationEnabled.value = false;
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        isLocationEnabled.value = true;
        await getCurrentLocation();
      }
    } catch (e) {
      errorMessage.value = 'Failed to check location permission: $e';
      logger.e('Location permission error: $e');
    }
  }

  var address = ''.obs;

  Future<void> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      Placemark place = placemarks[0];

      address.value =
          "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
    } catch (e) {
      address.value = "Unknown Location";
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      currentPosition.value = position;

      await getAddressFromLatLng(position.latitude, position.longitude);
      isLoading.value = false;
      logger.i('Current location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      errorMessage.value = 'Failed to get current location: $e';
      logger.e('Get location error: $e');
      isLoading.value = false;
    }
  }

  Future<bool> isWithinProximity(
    double targetLatitude,
    double targetLongitude,
  ) async {
    try {
      await getCurrentLocation();

      if (currentPosition.value == null) {
        errorMessage.value = 'Unable to determine current location';
        return false;
      }

      final distance = Geolocator.distanceBetween(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        targetLatitude,
        targetLongitude,
      );

      logger.i('Distance to target: ${distance.toStringAsFixed(2)} meters');

      return distance <= proximityRadius;
    } catch (e) {
      errorMessage.value = 'Failed to check proximity: $e';
      logger.e('Proximity check error: $e');
      return false;
    }
  }

  double getDistanceToLocation(double latitude, double longitude) {
    if (currentPosition.value == null) {
      return -1;
    }

    return Geolocator.distanceBetween(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
      latitude,
      longitude,
    );
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  String formatDistance(double distance) {
    if (distance < 0) {
      return 'Unknown';
    } else if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)}km';
    }
  }
}
