import 'dart:io';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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

  static Future<Map<String, dynamic>> createProduct(
    XFile image,
    String title,
    String description,
    double price,
    int stock,
  ) async {
    final Dio dio = Dio();
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(image.path),
      'title': title,
      'description': description,
      'price': price,
      'stock': stock,
    });

    final response =
        await dio.post('${ApiConstants.productsUrl}/', data: formData);
    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to create product');
    }
  }

  static Future<Map<String, dynamic>> fetchProductDetail(int productId) async {
    final Dio dio = Dio();
    try {
      final response =
          await dio.get('${ApiConstants.productsUrl}/$productId/detail');
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load product detail');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateProduct(
    int productId,
    String title,
    String description,
    double price,
    int stock, {
    File? image,
  }) async {
    final Dio dio = Dio();
    try {
      // Prepare form data
      FormData formData = FormData.fromMap({
        '_method': 'PUT',
        'title': title,
        'description': description,
        'price': price,
        'stock': stock,
        if (image != null)
          'image': await MultipartFile.fromFile(image.path,
              filename: image.path.split('/').last),
      });

      final response = await dio.post(
        '${ApiConstants.productsUrl}/$productId/update',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<void> deleteProduct(int productId) async {
    final Dio dio = Dio();
    try {
      final response = await dio.delete(
        '${ApiConstants.productsUrl}/$productId',
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
