import '../../../../../config/api_path.dart';
import '../../../../../core/service/webservice/dio_helper.dart';

abstract class ForgetDataSource {
  Future<bool> resetPassword(
      {required String email, required String code, required String password});
}

class ForgetDataSourceImpl extends ForgetDataSource {
  final ApiService apiService;

  ForgetDataSourceImpl(this.apiService);

  @override
  Future<bool> resetPassword(
      {required String email,
      required String code,
      required String password}) async {
    await apiService.post(url: ApiPath.changePassword, requestBody: {
      'email': email,
      'otp': code,
      'password': password,
      'password_confirmation': password,
    });
    return true;
  }
}
