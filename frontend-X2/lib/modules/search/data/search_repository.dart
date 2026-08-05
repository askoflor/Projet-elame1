import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/entities/provider_model.dart';

class SearchRepository {
  final Dio _dio = DioClient.instance;

  Future<List<ProviderModel>> rechercherPrestataires({
    String? specialite,
    String? quartier,
    bool? disponible,
    DateTime? date,
  }) async {
    try {
      final response = await _dio.get('/search/providers', queryParameters: {
        if (specialite != null && specialite.isNotEmpty) 'specialite': specialite,
        if (quartier != null && quartier.isNotEmpty) 'quartier': quartier,
        if (disponible != null) 'disponible': disponible,
        if (date != null) 'date': _formatDate(date),
      });
      return (response.data as List).map((e) => ProviderModel.fromSearchJson(e as Map<String, dynamic>)).toList();
    } on DioException {
      return [];
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
