import 'package:flutter/material.dart';
import 'package:inixindo_flutter/modules/location/data/locationApi.dart';
import 'package:inixindo_flutter/modules/location/models/locationResponseModel.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _locationApi = Locationapi();
  bool _isLoading = true;
  List<Data> _trackingsList = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTrackings();
  }

  Future<void> _fetchTrackings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _locationApi.getTrackings();

    // DEBUG: Tampilkan semua data respon di terminal
    print('=== DEBUG: AMBIL DATA TRACKINGS ===');
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

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          _trackingsList = result.data ?? [];
        } else {
          _errorMessage = 'Gagal mengambil data tracking dari server.';
        }
      });
    }
  }

  IconData _getIconForPlaceType(String? type) {
    if (type == null) return Icons.location_on;
    switch (type.toLowerCase()) {
      case 'kantor':
      case 'office':
      case 'work':
        return Icons.work_outlined;
      case 'rumah':
      case 'home':
        return Icons.home_outlined;
      case 'toko':
      case 'store':
      case 'shop':
        return Icons.store_outlined;
      default:
        return Icons.location_on_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Lokasi Tracking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTrackings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchTrackings,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _trackingsList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada data tracking lokasi.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _trackingsList.length,
              itemBuilder: (context, index) {
                final item = _trackingsList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon tag tempat
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getIconForPlaceType(item.placeType),
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Detail
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.placeName ?? 'Lokasi Tanpa Nama',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (item.placeType != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.placeType!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[800],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (item.comment != null &&
                                  item.comment!.isNotEmpty) ...[
                                Text(
                                  item.comment!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                              Row(
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Lat: ${item.latitude}, Lng: ${item.longitude}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
