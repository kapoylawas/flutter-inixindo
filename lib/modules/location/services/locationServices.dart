import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();

  /// Mendapatkan lokasi saat ini setelah memeriksa status layanan GPS dan izin akses lokasi.
  /// Mengembalikan [LocationData] jika sukses, atau null jika gagal atau ditolak.
  Future<LocationData?> getCurrentLocation() async {
    try {
      // 1. Periksa apakah layanan lokasi (GPS) aktif
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('Layanan lokasi dinonaktifkan oleh pengguna.');
          return null;
        }
      }

      // 2. Periksa status izin akses lokasi
      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted &&
            permissionGranted != PermissionStatus.grantedLimited) {
          print('Izin lokasi ditolak oleh pengguna.');
          return null;
        }
      }

      // 3. Ambil data lokasi
      return await _location.getLocation();
    } catch (e) {
      print('Terjadi kesalahan saat mengambil lokasi: $e');
      return null;
    }
  }
}
