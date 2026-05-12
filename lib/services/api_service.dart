import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/product_model.dart';

class ApiService {
  static const String _baseUrl = 'https://task.itprojects.web.id';

  // AUTH
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'token': data['data']['token'],
          'user': UserModel.fromJson(data['data']['user']),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal. Periksa kredensial.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal. Periksa jaringan internet.',
      };
    }
  }

  // PRODUCTS
  static Future<List<ProductModel>> getProducts(String token) async {
    final url = Uri.parse('$_baseUrl/api/products');

    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final List raw = data['data']['products'];
      return raw.map((e) => ProductModel.fromJson(e)).toList();
    }

    throw Exception(data['message'] ?? 'Gagal memuat produk.');
  }

  static Future<Map<String, dynamic>> addProduct(
    String token,
    String name,
    int price,
    String description,
  ) async {
    final url = Uri.parse('$_baseUrl/api/products');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'price': price,
              'description': description,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menambahkan produk.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal. Periksa jaringan internet.',
      };
    }
  }

  // SUBMIT TUGAS
  static Future<Map<String, dynamic>> submitTugas(
    String token,
    String name,
    int price,
    String description,
    String githubUrl,
  ) async {
    final url = Uri.parse('$_baseUrl/api/products/submit');

    try {
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'price': price,
              'description': description,
              'github_url': githubUrl,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal submit tugas.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Koneksi gagal. Periksa jaringan internet.',
      };
    }
  }
}