import 'dart:io';

import 'package:crud_image_laravel_flutter/constants/api_constants.dart';
import 'package:crud_image_laravel_flutter/models/product.dart';
import 'package:crud_image_laravel_flutter/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/product_list_screen.dart';

class UpdateProductScreen extends StatefulWidget {
  final int productId;
  final Product product;

  const UpdateProductScreen({
    super.key,
    required this.productId,
    required this.product,
  });

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the existing product data
    _titleController = TextEditingController(text: widget.product.title);
    _descriptionController =
        TextEditingController(text: widget.product.description);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _stockController =
        TextEditingController(text: widget.product.stock.toString());
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      // setState(() {
      //   _isLoading = true;
      // });

      try {
        // Use the updated data, including image if provided
        await ApiService.updateProduct(
          widget.productId,
          _titleController.text,
          _descriptionController.text,
          double.parse(_priceController.text),
          int.parse(_stockController.text),
          image: _imageFile,
        );

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.push(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const ProductListScreen(),
            ), // Ganti dengan layar tujuan
          );
        });
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display existing product image if available
                      if (_imageFile != null)
                        // Show newly selected image
                        Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      else if (widget.product.image.isNotEmpty)
                        // Show existing image only if no new image is selected
                        Image.network(
                          '${ApiConstants.imgUrl}/${widget.product.image}',
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Pick Image'),
                      ),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) =>
                            value!.isEmpty ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        validator: (value) =>
                            value!.isEmpty ? 'Description is required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Price is required' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Stock is required' : null,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProduct,
                          child: const Text('Update Product'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
