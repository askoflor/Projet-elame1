import 'package:dio/dio.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../domain/intervention.dart';
import '../domain/provider_schedule_entry.dart';

class InterventionRepository {
  final Dio _dio = DioClient.instance;

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Intervention?> creer({
    required String providerName,
    required String service,
    required String titre,
    String description = '',
    required DateTime date,
    required List<int> heures,
    required String urgence,
    required String adresse,
  }) async {
    try {
      final response = await _dio.post(AppConfig.interventionsEndpoint, data: {
        'providerName': providerName,
        'service': service,
        'titre': titre,
        'description': description,
        'date': _fmtDate(date),
        'heures': heures,
        'urgence': urgence,
        'adresse': adresse,
      });
      return Intervention.fromJson(response.data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<List<Intervention>> mesInterventions() async {
    try {
      final response = await _dio.get(AppConfig.myInterventionsEndpoint);
      return (response.data as List).map((e) => Intervention.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ProviderScheduleEntry>> planningPrestataire(String providerName) async {
    try {
      final response = await _dio.get(
        AppConfig.interventionsPlanningEndpoint,
        queryParameters: {'providerName': providerName},
      );
      return (response.data as List).map((e) => ProviderScheduleEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Intervention?> chiffrer(
    String reference, {
    required double montant,
    DateTime? dateConfirmee,
    String? note,
  }) async {
    try {
      final response = await _dio.post('${AppConfig.interventionsEndpoint}/$reference/chiffrer', data: {
        'montant': montant,
        if (dateConfirmee != null) 'dateConfirmee': _fmtDate(dateConfirmee),
        if (note != null) 'note': note,
      });
      return Intervention.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<Intervention?> terminer(
    String reference, {
    required String description,
    required List<String> photos,
  }) async {
    try {
      final response = await _dio.post('${AppConfig.interventionsEndpoint}/$reference/terminer', data: {
        'description': description,
        'photos': photos,
      });
      return Intervention.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }

  Future<Intervention?> annuler(String reference) async {
    try {
      final response = await _dio.post('${AppConfig.interventionsEndpoint}/$reference/annuler');
      return Intervention.fromJson(response.data as Map<String, dynamic>);
    } on DioException {
      return null;
    }
  }
}
