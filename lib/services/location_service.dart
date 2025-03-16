import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationService {
  // Check if the user is within the building premises
  static Future<bool> isUserInPremises(double buildingLat, double buildingLong, double radiusInMeters) async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, return false
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
        content: Text(
          "You have disabled location of your device!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      return false;
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, return false
        ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
          content: Text(
            "You have denier location permission!",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, return false
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
        content: Text(
          "You have denier location permission forever!",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
      return false;
    }
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
    print("Lat: $buildingLat, Lng: $buildingLong, Radius: $radiusInMeters Status: ${distance <= radiusInMeters} | USER LOCATION: ${userPosition.latitude} ${userPosition.longitude}");

    // Check if the user is within the radius
    return distance <= radiusInMeters;
  }
}
