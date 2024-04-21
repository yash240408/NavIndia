import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/login/login_controller.dart';
import '/features/authentication/screens/signup/signup.dart';
import '/utils/constants/sizes.dart';
import '/utils/constants/text_strings.dart';

class TLoginForm extends StatelessWidget {
  TLoginForm({super.key});
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return GetBuilder<TSignInController>(
      init: TSignInController(),
      builder: (controller) {
        return Form(
          key: controller.loginFormKey,
          child: Column(
            children: [
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: emailController,
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
                controller: passwordController,
                keyboardType: TextInputType.name,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Do you have not any acount ?',
                    style: TextStyle(fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(() => const SignupScreen());
                    },
                    child: const Text('Sign Up here..'),
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loginController.isLoading.isTrue
                        ? null
                        : () async {
                            if (controller.loginFormKey.currentState!
                                .validate()) {
                              await loginController.signIn(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim());
                            }
                          },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        side: const BorderSide(color: Colors.amber)),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Submit'),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        );
      },
    );
  }
}

class TSignInController extends GetxController {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  bool passwordVisible = false;

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
      return 'Password must have 8 characters and contain 1 Uppercase, Lowercase, Digit & Special Character.';
    }
    return null;
  }

  void togglePasswordVisibility() {
    passwordVisible = !passwordVisible;
    update(); // Notify GetX that the state has changed
  }
}
