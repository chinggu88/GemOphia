import '../models/user_model.dart';
import '../providers/api_provider.dart';

class UserRepository {
  final ApiProvider apiProvider;

  UserRepository({required this.apiProvider});

  Future<UserModel?> getUser(String userId) async {
    final response = await apiProvider.getUser(userId);

    if (response.status.hasError) {
      return null;
    }

    return UserModel.fromJson(response.body);
  }

  Future<bool> createUser(UserModel user) async {
    final response = await apiProvider.postUser(user.toJson());
    return response.status.isOk;
  }

  Future<bool> updateUser(String userId, UserModel user) async {
    final response = await apiProvider.updateUser(userId, user.toJson());
    return response.status.isOk;
  }

  Future<bool> deleteUser(String userId) async {
    final response = await apiProvider.deleteUser(userId);
    return response.status.isOk;
  }
}
