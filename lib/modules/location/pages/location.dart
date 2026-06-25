import 'package:flutter/material.dart';
import 'package:inixindo_flutter/modules/location/data/locationApi.dart';
import 'package:inixindo_flutter/modules/location/models/locationResponseModel.dart';
import 'package:inixindo_flutter/modules/location/pages/locationForm.dart';
import 'package:inixindo_flutter/modules/login/data/loginDb.dart';
import 'package:inixindo_flutter/modules/login/pages/login.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final _locationApi = Locationapi();

  bool _isLoadingLocal = true;
  bool _isLoadingPhp = true;

  List<Data> _localTrackingsList = [];
  List<Data> _phpLocationsList = [];

  String? _localErrorMessage;
  String? _phpErrorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLocalTrackings();
    _fetchPhpLocations();
  }

  Future<void> _fetchLocalTrackings() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocal = true;
      _localErrorMessage = null;
    });

    final result = await _locationApi.getTrackings();

    // DEBUG: Tampilkan semua data respon di terminal
    print('=== DEBUG: AMBIL DATA LOCAL TRACKINGS ===');
    if (result != null) {
      print('=== DEBUG: BERHASIL AMBIL DATA LOCAL TRACKINGS ===');
      print('Jumlah data: ${result.data?.length}');
      print('===========================================');
    } else {
      print('=== DEBUG: GAGAL AMBIL DATA LOCAL TRACKINGS ===');
    }

    if (mounted) {
      setState(() {
        _isLoadingLocal = false;
        if (result != null) {
          _localTrackingsList = result.data ?? [];
        } else {
          _localErrorMessage = 'Gagal mengambil data tracking dari server.';
        }
      });
    }
  }

  Future<void> _fetchPhpLocations() async {
    if (!mounted) return;
    setState(() {
      _isLoadingPhp = true;
      _phpErrorMessage = null;
    });

    final result = await _locationApi.getLokasiPhp();

    // DEBUG: Tampilkan semua data respon di terminal
    print('=== DEBUG: AMBIL DATA LOKASI PHP ===');
    if (result != null) {
      print('=== DEBUG: BERHASIL AMBIL DATA LOKASI PHP ===');
      print('Jumlah data: ${result.data?.length}');
      print('===========================================');
    } else {
      print('=== DEBUG: GAGAL AMBIL DATA LOKASI PHP ===');
    }

    if (mounted) {
      setState(() {
        _isLoadingPhp = false;
        if (result != null) {
          _phpLocationsList = result.data ?? [];
        } else {
          _phpErrorMessage = 'Gagal mengambil data lokasi dari server PHP.';
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

  Future<void> _confirmDelete(int? id, String? documentId) async {
    final targetId = documentId ?? id?.toString();
    if (targetId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Tracking'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data tracking lokasi ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoadingLocal = true;
      });

      final success = await _locationApi.deleteTracking(targetId);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data tracking berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchLocalTrackings();
        } else {
          setState(() {
            _isLoadingLocal = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus data tracking.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDeletePhp(int? id) async {
    if (id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Lokasi PHP'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data lokasi PHP ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoadingPhp = true;
      });

      final success = await _locationApi.deleteLokasiPhp(id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data lokasi PHP berhasil dihapus!'),
              backgroundColor: Colors.green,
            ),
          );
          _fetchPhpLocations();
        } else {
          setState(() {
            _isLoadingPhp = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus data lokasi PHP.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar Aplikasi'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await LoginDb.instance.clearSession();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Daftar Lokasi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.cloud_outlined), text: 'Local Tracking'),
              Tab(icon: Icon(Icons.map_outlined), text: 'Inixindo Jogja'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Muat Ulang',
              onPressed: () {
                _fetchLocalTrackings();
                _fetchPhpLocations();
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Keluar',
              onPressed: () => _handleLogout(),
            ),
          ],
        ),
        body: TabBarView(
          children: [_buildLocalTrackingsTab(), _buildPhpLocationsTab()],
        ),
      ),
    );
  }

  Widget _buildLocalTrackingsTab() {
    return Scaffold(
      body: _isLoadingLocal
          ? const Center(child: CircularProgressIndicator())
          : _localErrorMessage != null
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
                      _localErrorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchLocalTrackings,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _localTrackingsList.isEmpty
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
              itemCount: _localTrackingsList.length,
              itemBuilder: (context, index) {
                final item = _localTrackingsList[index];
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
                        // IconButton(
                        //   icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        //   onPressed: () async {
                        //     final result = await Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => LocationForm(trackingData: item),
                        //       ),
                        //     );
                        //     if (result == true) {
                        //       _fetchLocalTrackings();
                        //     }
                        //   },
                        // ),
                        // IconButton(
                        //   icon: const Icon(Icons.delete_outline, color: Colors.red),
                        //   onPressed: () => _confirmDelete(item.id, item.documentId),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LocationForm()),
          );
          if (result == true) {
            _fetchLocalTrackings();
          }
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Tambah Lokasi',
        child: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }

  Widget _buildPhpLocationsTab() {
    return Scaffold(
      body: _isLoadingPhp
          ? const Center(child: CircularProgressIndicator())
          : _phpErrorMessage != null
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
                      _phpErrorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchPhpLocations,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          : _phpLocationsList.isEmpty
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
                    'Tidak ada data lokasi dari server PHP.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _phpLocationsList.length,
              itemBuilder: (context, index) {
                final item = _phpLocationsList[index];
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
                        // Icon pin lokasi
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.location_on,
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
                                  if (item.kontributor != null &&
                                      item.kontributor!.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.green.withOpacity(0.2),
                                        ),
                                      ),
                                      child: Text(
                                        'Oleh: ${item.kontributor!}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green[800],
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
                        // IconButton(
                        //   icon: const Icon(
                        //     Icons.edit_outlined,
                        //     color: Colors.blue,
                        //   ),
                        //   onPressed: () async {
                        //     final result = await Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => LocationForm(
                        //           trackingData: item,
                        //           isPhpApi: true,
                        //         ),
                        //       ),
                        //     );
                        //     if (result == true) {
                        //       _fetchPhpLocations();
                        //     }
                        //   },
                        // ),
                        // IconButton(
                        //   icon: const Icon(
                        //     Icons.delete_outline,
                        //     color: Colors.red,
                        //   ),
                        //   onPressed: () => _confirmDeletePhp(item.id),
                        // ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationForm(isPhpApi: true),
            ),
          );
          if (result == true) {
            _fetchPhpLocations();
          }
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'Tambah Lokasi PHP',
        child: const Icon(Icons.add_location_alt_outlined),
      ),
    );
  }
}
