import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check if the user is within the building premises
  Future<bool> isUserInPremises(
      double buildingLat, double buildingLong, double radiusInMeters) async {
    // Get the user's current location
    Position userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Calculate the distance between the user and the building
    double distance = Geolocator.distanceBetween(
      buildingLat,
      buildingLong,
      userPosition.latitude,
      userPosition.longitude,
    );

    // Check if the user is within the radius
    return distance <= radiusInMeters;
  }
}
