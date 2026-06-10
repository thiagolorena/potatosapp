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
  Future<Response<dynamic>> adminCategories() => dio.get('/categories/admin');
  Future<Response<dynamic>> createCategory(Map<String, dynamic> data) => dio.post('/categories', data: data);
  Future<Response<dynamic>> updateCategory(int id, Map<String, dynamic> data) => dio.put('/categories/$id', data: data);

  Future<Response<dynamic>> calendar(int categoryId) => dio.get('/calendar/category/$categoryId');
  Future<Response<dynamic>> createCalendarEvent(Map<String, dynamic> data) => dio.post('/calendar', data: data);
  Future<Response<dynamic>> updateCalendarEvent(int id, Map<String, dynamic> data) => dio.put('/calendar/$id', data: data);

  Future<Response<dynamic>> standings(int categoryId) => dio.get('/standings/category/$categoryId');
  Future<Response<dynamic>> pilots() => dio.get('/users/pilots');
  Future<Response<dynamic>> createStanding(Map<String, dynamic> data) => dio.post('/standings', data: data);
  Future<Response<dynamic>> updateStanding(int id, Map<String, dynamic> data) => dio.put('/standings/$id', data: data);
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
