import 'package:dio/dio.dart';
import '../models/product.dart';
import '../constants/api_constants.dart';

class ApiService {
  final Dio dio;

  ApiService({required this.dio});

  Future<Map<String, dynamic>> getProducts({int page = 1}) async {
    final response = await dio.get('${ApiConstants.productsUrl}?page=$page');
    if (response.statusCode == 200) {
      final List<dynamic> productList = response.data['data']['data']; // Produk
      final int currentPage = response.data['data']['current_page'];
      final int totalPages = response.data['data']['last_page'];

      return {
        'products': productList.map((json) => Product.fromJson(json)).toList(),
        'currentPage': currentPage,
        'totalPages': totalPages,
      };
    } else {
      throw Exception('Failed to load products');
    }
  }
}
