import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/image_picker_helper.dart';
import '../services/api_service.dart';
import '../screens/product_list_screen.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  XFile? _pickedImage;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _pickedImage != null) {
      try {
        final response = await ApiService.createProduct(
          _pickedImage!,
          _titleController.text,
          _descriptionController.text,
          double.parse(_priceController.text),
          int.parse(_stockController.text),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
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
          SnackBar(content: Text('Failed to create product: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async {
                  final image = await ImagePickerHelper.pickImage();
                  setState(() {
                    _pickedImage = image;
                  });
                },
                child: _pickedImage != null
                    ? Image.file(
                        File(_pickedImage!.path),
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.add_a_photo),
                      ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Enter a valid stock';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
