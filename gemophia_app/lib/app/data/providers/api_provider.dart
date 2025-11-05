import 'package:get/get.dart';

class ApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'YOUR_API_BASE_URL';
    httpClient.timeout = const Duration(seconds: 30);

    // Add request modifier
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      return request;
    });

    // Add response modifier
    httpClient.addResponseModifier((request, response) {
      return response;
    });

    super.onInit();
  }

  Future<Response> getUser(String userId) async {
    return await get('/users/$userId');
  }

  Future<Response> postUser(Map<String, dynamic> data) async {
    return await post('/users', data);
  }

  Future<Response> updateUser(String userId, Map<String, dynamic> data) async {
    return await put('/users/$userId', data);
  }

  Future<Response> deleteUser(String userId) async {
    return await delete('/users/$userId');
  }
}
