import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/dio_client.dart';

class AvailabilityRepository {
  final Dio _dio = DioClient.instance;

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Renvoie les exceptions de disponibilite sous forme {"yyyy-MM-dd": bool}.
  Map<String, bool> _parse(dynamic data) {
    final overrides = <String, bool>{};
    for (final entry in (data as List)) {
      final map = entry as Map<String, dynamic>;
      final date = map['date'] as String;
      overrides[date] = map['disponible'] as bool;
    }
    return overrides;
  }

  Future<Map<String, bool>> mesDisponibilites() async {
    try {
      final response = await _dio.get(AppConfig.myAvailabilityEndpoint);
      return _parse(response.data);
    } on DioException {
      return {};
    }
  }

  Future<Map<String, bool>> disponibilitesPrestataire(String providerName) async {
    try {
      final response = await _dio.get(AppConfig.availabilityEndpoint, queryParameters: {'providerName': providerName});
      return _parse(response.data);
    } on DioException {
      return {};
    }
  }

  Future<Map<String, bool>?> basculerDate(DateTime date) async {
    try {
      final response = await _dio.post(AppConfig.availabilityToggleEndpoint, data: {'date': _fmtDate(date)});
      return _parse(response.data);
    } on DioException {
      return null;
    }
  }

  Future<Map<String, bool>?> definirPeriode(DateTime debut, DateTime fin, bool disponible) async {
    try {
      final response = await _dio.post(AppConfig.availabilityRangeEndpoint, data: {
        'dateDebut': _fmtDate(debut),
        'dateFin': _fmtDate(fin),
        'disponible': disponible,
      });
      return _parse(response.data);
    } on DioException {
      return null;
    }
  }
}
