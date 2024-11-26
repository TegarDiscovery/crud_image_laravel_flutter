import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../models/product.dart';
import '../constants/api_constants.dart';
import '../screens/product_form_screen.dart';
import '../screens/product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late ApiService apiService;
  List<Product> products = [];
  bool isLoading = true; // Loading saat data pertama kali dimuat
  bool isLoadingMore = false; // Loading untuk pagination
  String errorMessage = '';
  int currentPage = 1; // Halaman saat ini
  int totalPages = 1; // Total halaman dari API

  @override
  void initState() {
    super.initState();
    apiService = ApiService(dio: Dio());
    _fetchProducts(); // Memuat data pertama kali
  }

  // Mengambil produk dari API (untuk halaman tertentu)
  Future<void> _fetchProducts({int page = 1}) async {
    try {
      setState(() {
        if (page == 1) {
          isLoading = true;
        } else {
          isLoadingMore = true;
        }
        errorMessage = '';
      });

      final response = await apiService.getProducts(page: page);
      setState(() {
        if (page == 1) {
          products = response['products'];
        } else {
          products.addAll(response['products']); // Tambahkan data baru
        }

        currentPage = response['currentPage'];
        totalPages = response['totalPages'];
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
        errorMessage = 'Gagal memuat produk: $e';
      });
    }
  }

  // Fungsi untuk memuat data tambahan (pagination)
  Future<void> _loadMore() async {
    if (currentPage < totalPages && !isLoadingMore) {
      await _fetchProducts(page: currentPage + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        !isLoadingMore) {
                      _loadMore(); // Panggil fungsi loadMore saat scroll ke bawah
                    }
                    return false;
                  },
                  child: RefreshIndicator(
                    onRefresh: () => _fetchProducts(page: 1),
                    child: ListView.builder(
                      itemCount: products.length + 1, // Tambah 1 untuk loader
                      itemBuilder: (context, index) {
                        if (index < products.length) {
                          final product = products[index];
                          return ListTile(
                            // ignore: unnecessary_null_comparison
                            leading: product.image != null
                                ? Image.network(
                                    '${ApiConstants.imgUrl}/${product.image}',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image_not_supported),
                            title: Text(product.title),
                            subtitle: Text(product.description),
                            trailing: Text('Rp ${product.price}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                      productId: product.id),
                                ),
                              );
                            },
                          );
                        } else {
                          // Tampilkan loader saat memuat data tambahan
                          return isLoadingMore
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke ProductFormScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormScreen()),
          );
        },
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
