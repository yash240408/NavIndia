import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../screens/signup/verify_email.dart';

class SignupController extends GetxController {
  RxBool isLoading = false.obs;
  Future<void> signup(
      {required String email,
      required String password,
      required String phoneNo,
      required String name,
      required}) async {
    dynamic db = FirebaseFirestore.instance;
    try {
      // Check if the email or phone number already exists
      QuerySnapshot emailQuery = await db
          .collection("user_details")
          .where("email", isEqualTo: email.trim())
          .get();

      QuerySnapshot phoneQuery = await db
          .collection("user_details")
          .where("phone", isEqualTo: phoneNo.trim())
          .get();

      if (emailQuery.docs.isNotEmpty || phoneQuery.docs.isNotEmpty) {
        Fluttertoast.showToast(msg: "Email Or Phone Number Already Registered");
        return;
      } else {
        final sharedPref = GetStorage();
        sharedPref.write("signup_name", name.trim());
        sharedPref.write("signup_email", email.trim());
        sharedPref.write("signup_phone", phoneNo.trim());
        sharedPref.write("signup_password", password.trim());
        Get.offAll(() => const VerifyEmailScreen());
      }

      isLoading.value = false;
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
