import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class TrafficLightStream extends StatefulWidget {
  @override
  _TrafficLightStreamState createState() => _TrafficLightStreamState();
}

class _TrafficLightStreamState extends State<TrafficLightStream> {
  StreamController<Map<String, dynamic>> _streamController =
      StreamController<Map<String, dynamic>>();

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startStreaming();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _fetchData();
    });
  }

  void _startStreaming() async {
    _fetchData();
  }

  Future<void> _fetchData() async {
    final url = Uri.parse(
        'https://3f9da998-e880-42a7-bc03-1d570194259f-00-k8w3ex1ge8ww.sisko.replit.dev/traffic-signal');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        _streamController.add(responseBody);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Traffic Light Stream'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: _streamController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Text('No data available');
            } else {
              final data = snapshot.data;
              return Column(
                children: [
                  for (var position in data!.keys)
                    Column(
                      children: [
                        Text('Latitude: ${data[position]['latitude']}'),
                        Text('Longitude: ${data[position]['longitude']}'),
                        Text('Remaining Time: ${data[position]['remaining_time']}'),
                        Text('Signal: ${data[position]['signal']}'),
                        SizedBox(height: 20),
                      ],
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    _timer.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }
}
