import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:navindia/features/authentication/screens/wallet/wallet_screen.dart';
import 'features/authentication/screens/pothole/add_pothole.dart';
import 'features/authentication/screens/homescreen/widgets/home_screen_form.dart';
import 'features/authentication/screens/homescreen/widgets/profile.dart';
import 'features/authentication/screens/story/story_screen.dart';
import 'utils/constants/colors.dart';
import 'utils/helpers/helper_functions.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkmode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
            height: 80,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            backgroundColor: darkmode ? TColors.black : TColors.white,
            indicatorColor: darkmode
                ? TColors.white.withOpacity(0.1)
                : TColors.black.withOpacity(0.1),
            destinations: const [
              NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.pan_tool_rounded), label: 'PotHole'),
              NavigationDestination(icon: Icon(Iconsax.story), label: 'Story'),
              NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
              NavigationDestination(
                  icon: Icon(Iconsax.wallet), label: 'Wallet'),
            ]),
      ),
      body: Obx(() => controller.Screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final Screens = [
    HomeScreen(),
    const AddPotHoleScreen(),
    const StoryScreen(),
    const Profile(),
    CustomerWalletScreen()
  ];
}
