import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage_service.dart';
import '../utils/app_constants.dart';
import 'auth_interceptor.dart';

final apiBaseUrlProvider = FutureProvider<String>((ref) {
  return ref.watch(tokenStorageServiceProvider).getBaseUrl();
});

final dioClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageServiceProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.defaultBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Client-Platform': 'mobile',
        'X-Requested-With': 'MyLife',
      },
    ),
  );

  // Gán baseUrl động từ storage
  dio.interceptors.add(AuthInterceptor(storage, dio));
  return dio;
});
