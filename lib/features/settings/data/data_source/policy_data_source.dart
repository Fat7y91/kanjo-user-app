import 'package:heraj/config/api_path.dart';

import '../../../../../core/service/webservice/dio_helper.dart';
import '../../domain/entities/message_entity.dart';

abstract class PrivacyPolicyDataSource {
  Future<Message> getPolicy();
  Future<Message> getWhoAreWe();
}

class PrivacyPolicyDataSourceImpl extends PrivacyPolicyDataSource {
  final ApiService apiService;

  PrivacyPolicyDataSourceImpl({required this.apiService});

  @override
  Future<Message> getPolicy() async {
    // final res = await apiService.get(url: ApiPath.support, returnDataOnly: false);
    //
    // final Message privacyPolicyModel =
    //     Message.fromJson((res['message'] as List).first);
    //
    // return privacyPolicyModel;
    await Future.delayed(Duration(seconds: 1));
    return dummyMessage;
  }

  @override
  Future<Message> getWhoAreWe() async {
    // final res = await apiService.get(url: ApiPath.support, returnDataOnly: false);
    //
    // final Message privacyPolicyModel =
    //     Message.fromJson((res['message'] as List).first);
    //
    // return privacyPolicyModel;
    await Future.delayed(Duration(seconds: 1));
    return dummyWhoAreWeMessage;
  }
}
