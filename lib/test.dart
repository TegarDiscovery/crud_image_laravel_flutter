import 'package:dio/dio.dart';

void main() async {
  // Initialize Dio
  final dio = Dio();

  // Define the API endpoint
  String apiUrl =
      'http://10.0.2.2:8000/api/products'; // Use the emulator's local address

  // try {
  //   // GET request
  Response response = await dio.get(apiUrl);
  print(response.toString());

  // Print the response data
  // print('Response data:');
  // print(response.data.toString());
  // } catch (e) {
  // Handle Dio exceptions
  // if (e is DioException) {
  // print('DioException: ${e.message}');
  // } else {
  // print('Error: $e');
  // }
  // }
}
