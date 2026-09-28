import '../../../../config/api_path.dart';
import '../../../../core/service/webservice/dio_helper.dart';
import '../models/wallet_model.dart';

abstract class WalletDataSource {
  Future<WalletModel> getWallet();
}

class WalletDataSourceImpl extends WalletDataSource {
  final ApiService apiService;

  WalletDataSourceImpl({required this.apiService});

  @override
  Future<WalletModel> getWallet() async {
    final res = await apiService.get(
      url: ApiPath.getWallet,
      returnDataOnly: true,
    );
    if (res is Map) {
      return WalletModel.fromJson(Map<String, dynamic>.from(res));
    }
    return const WalletModel.empty();
  }
}
