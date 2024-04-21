// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../navigation_menu.dart';

Future<void> addPotHoleController({
  required String latitude,
  required String imagePath,
  required String longitude,
  required String roadQuality,
  required String description,
  required String userId,
}) async {
  var sharedPref = GetStorage();
  await sharedPref.initStorage;
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Add data to rest_details collection
    DocumentReference docRef =
        await firestore.collection("pothole_details").add({
      "latitude": latitude.trim(),
      "longitude": longitude.trim(),
      "imagePath": imagePath.trim(),
      "userId": userId.trim(),
      "status": "SUBMITTED",
      "roadQuality": roadQuality.trim(),
      "description": description.trim(),
      "address": "https://www.google.com/maps?q=$latitude,$longitude",
      'story_added_time': FieldValue.serverTimestamp(),
    });
    Fluttertoast.showToast(msg: "Thanks for your contribution!");
    Get.offAll(() => const NavigationMenu());
  } catch (e) {
    debugPrint("Error: $e");
    Fluttertoast.showToast(msg: "Oops something went wrong!");
  }
}
