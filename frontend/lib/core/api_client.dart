import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Bearer token to every request if available
          final token = await _storage.read(key: _accessTokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // On 401, attempt silent token refresh once
          if (e.response?.statusCode == 401) {
            final refreshToken = await _storage.read(key: _refreshTokenKey);
            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                final refreshResp = await Dio().post(
                  '${ApiConstants.baseUrl}${ApiConstants.refresh}',
                  data: {'refreshToken': refreshToken},
                  options: Options(
                    headers: {'Content-Type': 'application/json'},
                  ),
                );
                final newToken =
                    refreshResp.data['data']['accessToken'] as String;
                await saveToken(newToken);

                // Retry the original request with new token
                final retryOptions = e.requestOptions.copyWith(
                  headers: {
                    ...e.requestOptions.headers,
                    'Authorization': 'Bearer $newToken',
                  },
                );
                final retryResp = await dio.fetch(retryOptions);
                return handler.resolve(retryResp);
              } catch (_) {
                // Refresh failed — clear tokens so user must re-login
                await clearToken();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
}
