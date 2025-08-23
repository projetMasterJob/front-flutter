import 'package:http/http.dart' as http;
import 'token_store.dart';
import 'auth_api.dart';
import 'auth_http_client.dart';

final TokenStore tokenStore = TokenStore();
final AuthApi authApi = const AuthApi(
  baseUrl: 'https://auth-service-kohl.vercel.app/api/auth',
);
final AuthHttpClient authClient = AuthHttpClient(
  http.Client(),
  tokenStore,
  authApi,
);
