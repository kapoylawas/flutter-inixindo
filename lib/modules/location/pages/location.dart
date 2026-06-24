import 'package:flutter/material.dart';
import 'package:inixindo_flutter/modules/location/data/locationApi.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _locationApi = Locationapi();

  @override
  void initState() {
    super.initState();
    _debugFetchTrackings();
  }

  Future<void> _debugFetchTrackings() async {
    print('=== DEBUG: AMBIL DATA TRACKINGS ===');
    final result = await _locationApi.getTrackings();

    if (result != null) {
      print('=== DEBUG: BERHASIL AMBIL DATA TRACKINGS ===');
      print('Raw Response JSON: ${result.toJson()}');
      print('Jumlah data: ${result.data?.length}');
      if (result.data != null && result.data!.isNotEmpty) {
        for (var item in result.data!) {
          print('--- Item ID: ${item.id} ---');
          print('Document ID: ${item.documentId}');
          print('Place Name: ${item.placeName}');
          print('Place Type: ${item.placeType}');
          print('Comment: ${item.comment}');
          print('Latitude: ${item.latitude}');
          print('Longitude: ${item.longitude}');
          print('Created At: ${item.createdAt}');
          print('Updated At: ${item.updatedAt}');
          print('Published At: ${item.publishedAt}');
        }
      }
      print('===========================================');
    } else {
      print('=== DEBUG: GAGAL AMBIL DATA TRACKINGS ===');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'page location',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
