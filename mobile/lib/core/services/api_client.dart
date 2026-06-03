import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class ApiClient {
  ApiClient({required String baseUrl})
      : dio = Dio(BaseOptions(baseUrl: baseUrl, connectTimeout: const Duration(seconds: 10)));

  final Dio dio;

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<Response<dynamic>> login(String email, String password) {
    return dio.post('/auth/login', data: {'email': email, 'password': password});
  }

  Future<Response<dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required Uint8List photoBytes,
    required String photoName,
  }) {
    final data = FormData.fromMap({
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'photo': MultipartFile.fromBytes(photoBytes, filename: photoName),
    });
    return dio.post('/auth/register', data: data);
  }

  Future<Response<dynamic>> categories() => dio.get('/categories');
  Future<Response<dynamic>> calendar(int categoryId) => dio.get('/calendar/category/$categoryId');
  Future<Response<dynamic>> standings(int categoryId) => dio.get('/standings/category/$categoryId');
}

class ApiScope extends InheritedWidget {
  const ApiScope({required this.client, required super.child, super.key});

  final ApiClient client;

  static ApiClient of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ApiScope>();
    assert(scope != null, 'ApiScope nao encontrado na arvore.');
    return scope!.client;
  }

  @override
  bool updateShouldNotify(ApiScope oldWidget) => client != oldWidget.client;
}
