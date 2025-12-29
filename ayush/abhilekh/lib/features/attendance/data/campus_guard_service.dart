import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_constants.dart';

class CampusGuardService {
  final NetworkInfo networkInfo;

  CampusGuardService({required this.networkInfo});

  Future<void> validatePresence() async {
    // 1. Check & Request Permissions
    await _checkPermissions();

    // 2. Check WiFi BSSID
    final String? wifiBSSID = await networkInfo.getWifiBSSID();
    
    // Cleaning the BSSID string (removing quotes, lowercasing)
    final cleanBSSID = wifiBSSID?.replaceAll('"', '').toLowerCase().trim();
    final targetBSSID = AppConstants.campusBSSID.toLowerCase().trim();

    if (cleanBSSID != targetBSSID) {
      // NOTE: For Simulator testing, you might comment this throw out.
      // But for production, this is required.
      throw Exception(
        'Invalid WiFi.\nConnected: $cleanBSSID\nRequired: $targetBSSID'
      );
    }

    // 3. Check Geolocation
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final double distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      AppConstants.campusLat,
      AppConstants.campusLng,
    );

    if (distance > AppConstants.allowedRadiusMeters) {
      throw Exception(
        'You are outside campus.\nDistance: ${distance.toInt()}m\nLimit: ${AppConstants.allowedRadiusMeters}m'
      );
    }
  }

  Future<void> _checkPermissions() async {
    var locStatus = await Permission.location.status;
    if (!locStatus.isGranted) {
      await Permission.location.request();
    }
    
    // For Android 10+ sometimes specific wifi permissions are needed depending on target SDK
    // But usually location covers BSSID access.
  }
}