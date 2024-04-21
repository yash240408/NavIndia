import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../utils/constants/sizes.dart';
import '../../controllers/pothole/add_pothole_controller.dart';

class AddPotHoleScreen extends StatefulWidget {
  const AddPotHoleScreen({super.key});

  @override
  AddPotHoleScreenState createState() => AddPotHoleScreenState();
}

class AddPotHoleScreenState extends State<AddPotHoleScreen> {
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _descriptionController;
  File? productPhoto;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GlobalKey<FormState> _AddPotHoleScreenKey = GlobalKey<FormState>();
  TextEditingController foodName = TextEditingController();
  TextEditingController foodCat = TextEditingController();
  var isProcessing = false.obs;
  var isLoading = false.obs;
  var isLocationStored = false.obs;
  double _sliderValue = 1.0;
  final TextEditingController _potHoleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  Future<void> _getCurrentLocation() async {
    isLoading(true);
    try {
      Position? position;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await _showLocationServiceDisabledToast();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          await _showLocationPermissionDeniedToast();
          return;
        }
        if (permission == LocationPermission.deniedForever) {
          await _showLocationPermissionPermanentlyDeniedToast();
          return;
        }
      }

      position = await Geolocator.getCurrentPosition();
      _latitudeController.text = position.latitude.toString();
      _longitudeController.text = position.longitude.toString();
      isLocationStored(false); // Reset location stored status
      isLocationStored(true); // Show location stored status
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> _showLocationServiceDisabledToast() async {
    Fluttertoast.showToast(
      msg: 'Location services are disabled.\nPlease enable them to continue!',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<void> _showLocationPermissionDeniedToast() async {
    Fluttertoast.showToast(
      msg: 'Location permissions are denied.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<void> _showLocationPermissionPermanentlyDeniedToast() async {
    Fluttertoast.showToast(
      msg:
          'Location permissions are permanently denied.\nPlease enable them in app settings.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    _handleImageSelection(image);
  }

  Future<void> _selectPicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    _handleImageSelection(image);
  }

  void _handleImageSelection(XFile? image) {
    if (image != null) {
      setState(() {
        productPhoto = File(image.path);
      });
    }
  }

  Future<void> uploadPicture() async {
    if (_AddPotHoleScreenKey.currentState?.validate() ?? false) {
      var sharedPref = GetStorage();
      await sharedPref.initStorage;
      isProcessing(true);
      try {
        if (productPhoto != null) {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          String fileExtension = productPhoto!.path.split('.').last;
          String completeFileName = '$fileName.$fileExtension';

          Reference storageReference =
              _storage.ref().child('photos/').child(completeFileName);

          await storageReference.putFile(productPhoto!);

          String downloadURL = await storageReference.getDownloadURL();

          String currentStatus = "";

          if (_potHoleController.text.trim() == "1.0" ||
              _potHoleController.text.trim() == "2.0") {
            currentStatus = "NORMAL";
          } else if (_potHoleController.text.trim() == "3.0" ||
              _potHoleController.text.trim() == "4.0") {
            currentStatus = "MODERATE";
          } else {
            currentStatus = "SEVERE";
          }
          addPotHoleController(
              latitude: _latitudeController.text.trim(),
              longitude: _longitudeController.text.trim(),
              imagePath: downloadURL.trim(),
              userId: sharedPref.read("userId"),
              roadQuality: currentStatus.trim(),
              description: _descriptionController.text.trim());
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text(
                  "We need the pothole photo!",
                  textAlign: TextAlign.center,
                ),
                content: const Text(
                  "Please select / take a picture!",
                  textAlign: TextAlign.center,
                ),
                alignment: Alignment.center,
                actionsAlignment: MainAxisAlignment.center,
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.green.shade100),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        debugPrint('Firebase Storage Error: $e');
      } finally {
        isProcessing(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _AddPotHoleScreenKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 16,
                ),
                TextFormField(
                  readOnly: true,
                  controller: _latitudeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the latitude';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.location_add),
                    labelText: "Latitude",
                  ),
                ),
                const SizedBox(
                  height: TSizes.spaceBtwItems,
                ),
                TextFormField(
                  readOnly: true,
                  controller: _longitudeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the longitude';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.location),
                    labelText: "Longitude",
                  ),
                ),
                const SizedBox(
                  height: 22,
                ),
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isLoading.value ? null : _getCurrentLocation,
                      child: isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text('Current Location'),
                    ),
                  );
                }),
                const SizedBox(
                  height: 22,
                ),
                Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some description';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.information),
                      labelText: "Description",
                    ),
                  ),
                ),
                const SizedBox(
                  height: 22,
                ),
                const Text(
                  'Upload PotHole Image...',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(
                  height: 22,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade200,
                          side: const BorderSide(color: Colors.deepPurple)),
                      onPressed: _takePicture,
                      child: const Text('Take Picture'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.teal.shade200,
                          side: const BorderSide(color: Colors.cyan)),
                      onPressed: _selectPicture,
                      child: const Text('Select Picture'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (productPhoto != null)
                  Image.file(
                    productPhoto!,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 20),
                Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Slider(
                    label: "PotHole Condition",
                    value: _sliderValue,
                    min: 1.0,
                    max: 5.0,
                    divisions: 4,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                         if(_sliderValue >=1 && _sliderValue <=2){
                          _potHoleController.text = "NORMAL";
                        }
                        else if(_sliderValue >3 && _sliderValue <=4){
                          _potHoleController.text = "MODERATE";
                        }
                        if(_sliderValue >4 && _sliderValue <=5){
                          _potHoleController.text = "SEVERE";
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextFormField(
                    readOnly: true,
                    controller: _potHoleController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'PotHole Condition',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      double parsedValue = double.tryParse(value) ?? 1.0;
                      setState(() {
                        _sliderValue = parsedValue.clamp(1.0, 5.0);
                       
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 77, 237, 83),
                          side: const BorderSide(color: Colors.amber)),
                      onPressed: isProcessing.value ? null : uploadPicture,
                      child: isProcessing.value
                          ? const CircularProgressIndicator()
                          : const Text('Submit'),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
