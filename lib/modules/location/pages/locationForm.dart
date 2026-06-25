import 'package:flutter/material.dart';
import 'package:inixindo_flutter/modules/location/data/locationApi.dart';
import 'package:inixindo_flutter/modules/location/services/locationServices.dart';
import 'package:inixindo_flutter/modules/location/models/locationResponseModel.dart';

class LocationForm extends StatefulWidget {
  final Data? trackingData;
  const LocationForm({super.key, this.trackingData});

  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _formKey = GlobalKey<FormState>();
  final _placeNameController = TextEditingController();
  final _commentController = TextEditingController();

  final _placeTypeController = TextEditingController();

  final LocationService _locationService = LocationService();
  final Locationapi _locationApi = Locationapi();

  bool _isGettingLocation = false;
  bool _isSaving = false;
  double? _latitude;
  double? _longitude;



  @override
  void initState() {
    super.initState();
    if (widget.trackingData != null) {
      _placeNameController.text = widget.trackingData!.placeName ?? '';
      _placeTypeController.text = widget.trackingData!.placeType ?? '';
      _commentController.text = widget.trackingData!.comment ?? '';
      _latitude = widget.trackingData!.latitude;
      _longitude = widget.trackingData!.longitude;
    } else {
      _getCurrentDeviceLocation();
    }
  }

  @override
  void dispose() {
    _placeNameController.dispose();
    _commentController.dispose();
    _placeTypeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentDeviceLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    final locationData = await _locationService.getCurrentLocation();

    if (mounted) {
      setState(() {
        _isGettingLocation = false;
        if (locationData != null) {
          _latitude = locationData.latitude;
          _longitude = locationData.longitude;
          
          // DEBUG: Tampilkan koordinat di terminal saat berhasil didapatkan
          print('=== DEBUG: BERHASIL MENDAPATKAN LOKASI PERANGKAT ===');
          print('Latitude : ${locationData.latitude}');
          print('Longitude: ${locationData.longitude}');
          print('Accuracy : ${locationData.accuracy} meter');
          print('Altitude : ${locationData.altitude} meter');
          print('Speed    : ${locationData.speed} m/s');
          print('Time     : ${DateTime.fromMillisecondsSinceEpoch(locationData.time?.toInt() ?? 0)}');
          print('=====================================================');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Gagal mendapatkan lokasi. Pastikan GPS aktif dan izin diberikan.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
    }
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koordinat lokasi tidak boleh kosong. Harap deteksi lokasi terlebih dahulu.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = widget.trackingData != null
        ? await _locationApi.updateTracking(
            id: widget.trackingData!.documentId ?? widget.trackingData!.id?.toString(),
            placeName: _placeNameController.text.trim(),
            placeType: _placeTypeController.text.trim(),
            comment: _commentController.text.trim(),
            latitude: _latitude!,
            longitude: _longitude!,
          )
        : await _locationApi.postTracking(
            placeName: _placeNameController.text.trim(),
            placeType: _placeTypeController.text.trim(),
            comment: _commentController.text.trim(),
            latitude: _latitude!,
            longitude: _longitude!,
          );

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data lokasi berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali dengan hasil true untuk refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data ke server.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.trackingData != null ? 'Edit Lokasi Tracking' : 'Tambah Lokasi Tracking',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Koordinat GPS
              Card(
                elevation: 1,
                color: Colors.blue.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.my_location, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _latitude != null && _longitude != null
                                  ? 'Koordinat Terdeteksi'
                                  : 'Koordinat Belum Ada',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          if (_isGettingLocation)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          else
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.blue,
                              ),
                              onPressed: _getCurrentDeviceLocation,
                            ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Latitude',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _latitude != null ? _latitude.toString() : '-',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Longitude',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _longitude != null ? _longitude.toString() : '-',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Input Nama Tempat
              TextFormField(
                controller: _placeNameController,
                decoration: InputDecoration(
                  labelText: 'Nama Tempat',
                  hintText: 'Masukkan nama tempat (misal: Inixindo, Rumah, dll)',
                  prefixIcon: const Icon(Icons.place_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tempat wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Tipe Tempat
              TextFormField(
                controller: _placeTypeController,
                decoration: InputDecoration(
                  labelText: 'Tipe Tempat',
                  hintText: 'Masukkan tipe tempat (misal: Kantor, Rumah, Toko)',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tipe tempat wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input Catatan / Comment
              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Tambahkan catatan opsional mengenai lokasi ini',
                  prefixIcon: const Icon(Icons.comment_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isSaving ? null : _saveLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Simpan Lokasi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
