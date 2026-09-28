import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/service/auth_service.dart';
import '../../../../../../main.dart';
import '../../../../../models/user_model.dart';
import '../../../auth/domain/repositories/auth_repo.dart';

final refreshProfileProvider =
    FutureProvider.autoDispose<UserModel>((ref) async {
  ref.listenSelf((previous, next) {
    if (next.value is UserModel) {
      ref.read(userProvider.notifier).state = next.value;
    }
  });
  final res = await getIt<AuthRepo>().getMyProfile();
  return res.fold((l) => throw l, (r) => r);
});
