import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/signup/signup_controller.dart';
import '/utils/constants/sizes.dart';
import '/utils/constants/text_strings.dart';
import 'package:iconsax/iconsax.dart';

class TSignUpForm extends StatelessWidget {
  TSignUpForm({super.key});
  final SignupController _signupController = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TSignUpController>(
      init: TSignUpController(),
      builder: (controller) {
        return Form(
          key: controller._signupFormKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: controller.fullName,
                      validator: controller._validateName,
                      textCapitalization: TextCapitalization.words,
                      expands: false,
                      decoration: const InputDecoration(
                        labelText: TTexts.fullName,
                        prefixIcon: Icon(Iconsax.user),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: controller.emailAddress,
                validator: controller._validateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: TTexts.email,
                  prefixIcon: Icon(Iconsax.direct),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: controller.phoneNo,
                validator: controller._validatePhone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: TTexts.phoneNo,
                  prefixIcon: Icon(Iconsax.call),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: controller.password,
                validator: controller._validatePassword,
                obscureText: !controller.passwordVisible,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Iconsax.password_check5),
                  labelText: TTexts.password,
                  suffixIcon: IconButton(
                    icon: Icon(controller.passwordVisible
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              // const TTermsAndConditionCheckbox(),
              const SizedBox(height: TSizes.spaceBtwSections),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.green,
                          side: const BorderSide(color: Colors.amber)),
                      onPressed: _signupController.isLoading.value
                          ? null
                          : () async {
                              if (controller._signupFormKey.currentState!
                                  .validate()) {
                                await _signupController.signup(
                                    email: controller.emailAddress.text,
                                    password: controller.password.text,
                                    phoneNo: controller.phoneNo.text,
                                    name: controller.fullName.text);
                              }
                            },
                      child: _signupController.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text(TTexts.createAccount),
                    ),
                  )),
              const SizedBox(height: TSizes.spaceBtwSections),
              // const TFormDivider(
              //   dividerText: TTexts.orSignUpWith,
              // ),
              // const SizedBox(height: TSizes.spaceBtwSections),
              // const TSocialicon(),
            ],
          ),
        );
      },
    );
  }
}

class TSignUpController extends GetxController {
  final GlobalKey<FormState> _signupFormKey = GlobalKey<FormState>();
  bool passwordVisible = false;
  TextEditingController emailAddress = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController phoneNo = TextEditingController();

  String? _validateEmail(String? value) {
    if ((value == null || value.isEmpty)) {
      return 'Please enter your email';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
        .hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value == null || value.isEmpty)) {
      return 'Please enter your password';
    } else if (!RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(value)) {
      return 'Password must be have 8 character and contains 1 Uppercase, LowerCase, Digit & Special Character.';
    }
    return null;
  }

  String? _validateName(String? value) {
    if ((value == null || value.isEmpty)) {
      return 'Please enter your name';
    } else if (!RegExp(r'^[a-zA-Z]+ [a-zA-Z]+$').hasMatch(value)) {
      return 'Please enter your name in the format "First Last"';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if ((value == null || value.isEmpty)) {
      return 'Please enter your phone number';
    } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number\nstarting with 6-9';
    }
    return null;
  }

  void togglePasswordVisibility() {
    passwordVisible = !passwordVisible;
    update(); // Notify GetX that the state has changed
  }
}
