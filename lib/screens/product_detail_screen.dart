import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../constants/api_constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId; // Tipe data id sebagai int

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? productDetail; // Data produk
  bool isLoading = true; // Status loading
  String? errorMessage; // Simpan pesan error jika ada

  @override
  void initState() {
    super.initState();
    fetchProductDetail(); // Ambil detail produk saat initState
  }

  Future<void> fetchProductDetail() async {
    setState(() {
      isLoading = true; // Tampilkan loading
      errorMessage = null; // Reset pesan error
    });

    try {
      final data = await ApiService.fetchProductDetail(widget.productId);
      setState(() {
        productDetail = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString(); // Simpan error jika gagal
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Detail'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading spinner
          : errorMessage != null
              ? Center(child: Text('Error: $errorMessage')) // Tampilkan error
              : productDetail == null
                  ? const Center(
                      child: Text(
                          'Product not found')) // Jika produk tidak ditemukan
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                // Check if the image exists, otherwise use a placeholder or default image.
                                productDetail!['image'] != null &&
                                        productDetail!['image'] != ''
                                    ? '${ApiConstants.imgUrl}/${productDetail!['image']}'
                                    : 'https://via.placeholder.com/150', // URL of a placeholder image
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double
                                  .infinity, // Pastikan Card mengisi layar
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${productDetail!['title']}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Description: ${productDetail!['description'] ?? 'No description'}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Price: \$${productDetail!['price']}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
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
