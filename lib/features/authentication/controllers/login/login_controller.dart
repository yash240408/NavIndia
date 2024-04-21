import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:navindia/features/authentication/screens/signup/signup.dart';

import '../../../../navigation_menu.dart';
import '../../../../splash_screen.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      final sharedPref = GetStorage();
      await sharedPref.initStorage;
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      final userQuery = await FirebaseFirestore.instance
          .collection("user_details")
          .where("email", isEqualTo: credential.user?.email!.trim())
          .get();

      if (userQuery.docs.isNotEmpty) {
        final user = userQuery.docs.first.data();
        final userId = userQuery.docs.first.id;
        // Save user details and restaurantId
        sharedPref.write('isLogin', true);
        sharedPref.write(SplashScreenState.keylogin, true);
        sharedPref.write("userId", userId);
        sharedPref.write("name", user["fullname"]);
        sharedPref.write("email", user["email"]);
        sharedPref.write("phone", user["phone"]);
        Fluttertoast.showToast(msg: "Login Success");
        await sharedPref.save();

        if (sharedPref.read(SplashScreenState.keylogin) == true) {
          Get.offAll(() => const NavigationMenu());
        } else {
          Get.to(() => const SignupScreen());
        }
      } else {
        debugPrint("User not found in Firestore");
        Fluttertoast.showToast(msg: "Invalid Email or Password!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid Email or Password!");
      debugPrint("Sign In Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
