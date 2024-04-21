import 'package:get/get.dart';

import 'network_widget.dart';


class DependencyInjection {
  
  Future<void> init() async {
    Get.put<NetworkController>(NetworkController(),permanent:true);
  }
}