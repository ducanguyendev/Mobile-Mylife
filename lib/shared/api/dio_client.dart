import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage_service.dart';
import 'auth_interceptor.dart';

final dioClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageServiceProvider);
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Gán baseUrl động từ storage
  storage.getBaseUrl().then((url) {
    dio.options.baseUrl = url;
  });

  dio.interceptors.add(AuthInterceptor(storage, dio));
  dio.interceptors.add(LogInterceptor(
    requestHeader: false,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
  ));

  return dio;
});
