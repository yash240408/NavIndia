import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final LocationControllerBackup locationController = Get.put(LocationControllerBackup());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final position = locationController.userLocation.value;
          if (position == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 13,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              locationController.mapController = controller;
            },
            markers: locationController.markers,
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          locationController.centerMapToUserLocation();
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

class LocationControllerBackup extends GetxController {
  late GoogleMapController mapController;
  Rx<Position?> userLocation = Position(
    latitude: 23.129251475002764,
    longitude: 72.5447781028838,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    headingAccuracy: 0,
  ).obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      _potholeSubscription;
        StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>();
  Set<Marker> markers = {};
  late Timer _timer;

  @override
  void onInit() {
    startListeningToPositionStream();
    startListeningToPotholeStream();
    _startStreaming();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchData();
    });
    super.onInit();
  }

  void _startStreaming() async {
    _fetchData();
  }

  Future<void> _fetchData() async {
  final url = Uri.parse(
      'https://3f9da998-e880-42a7-bc03-1d570194259f-00-k8w3ex1ge8ww.sisko.repl.co/traffic-signal');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      
      BitmapDescriptor _getTrafficSignalIcon(String signal) {
        
        switch (signal) {
          case 'red':
            return BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed);
          case 'green':
            return BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen);
          case 'yellow':
            return BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueYellow);
          default:
            return BitmapDescriptor.defaultMarker;
        }
      }
      for (var positionKey in responseBody.keys) {
        var position = responseBody[positionKey];
        markers.add(Marker(
          markerId: MarkerId(positionKey),
          position: LatLng(position['latitude'], position['longitude']),
          infoWindow: InfoWindow(
              title: 'Traffic Signal', snippet: position['remaining_time'].toString()),
          icon: _getTrafficSignalIcon(position['signal']),
        ));
         
      }
      update();
     
    } else {
      throw Exception('Failed to load data');
    }
  } catch (e) {
    print('Error fetching data: $e');
  }


}


  void startListeningToPotholeStream() {
    _potholeSubscription = _firestore
        .collection('pothole_details')
        .where('status', isEqualTo: 'verified')
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      markers.clear();
      for (final doc in snapshot.docs) {
        final latitudeString = doc['latitude'] as String?;
        final longitudeString = doc['longitude'] as String?;
        if (latitudeString != null && longitudeString != null) {
          final latitude = double.tryParse(latitudeString);
          final longitude = double.tryParse(longitudeString);
          if (latitude != null && longitude != null) {
            markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(latitude, longitude),
                infoWindow: InfoWindow(title: 'Pothole'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue),
              ),
            );
          }
        }
      }

      update();
    });
  }

  void startListeningToPositionStream() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      Fluttertoast.showToast(
        msg: 'Location permissions are denied.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
        msg:
            'Location permissions are permanently denied.\nPlease enable them in app settings.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      LocationSettings locationSettings;

      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
                "Nav.India is using your device location to send you the update of any order",
            notificationTitle: "Thank you for your service",
            enableWakeLock: true,
          ),
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
        );
      }
      Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      userLocation.value = position;
      Timer.periodic(const Duration(seconds: 30), (timer) async {
        try {
          Position? position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          userLocation.value = position;
          // await updateUserLocationInFirestore(position);
        } on LocationServiceDisabledException catch (e) {
          Fluttertoast.showToast(
            msg: 'Please enable location services for the best experience.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      });
    }
  }

  void centerMapToUserLocation() {
    final position = userLocation.value;
    if (position != null) {
      mapController.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    }
  }

  @override
  void onClose() {
    _potholeSubscription.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
    _potholeSubscription.cancel();
  }
}
