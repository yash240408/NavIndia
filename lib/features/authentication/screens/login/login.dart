import 'package:flutter/material.dart';
import '/common/styles/spacing_style.dart';
// import '/common/widgets/login_signup/social_icon.dart';
import '/features/authentication/screens/login/widgets/login_form.dart';
import '/features/authentication/screens/login/widgets/login_header.dart';
import '/utils/constants/sizes.dart';
import '/utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: TSpacingStyle.paddingWithAppBarHeight,
          child: Column(
            children: [
              TLoginHeader(dark: dark),
               TLoginForm(),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
