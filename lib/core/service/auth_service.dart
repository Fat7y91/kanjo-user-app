import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_firebase_chat/flutter_firebase_chat.dart' hide sl;
import '../../core/errors/failure.dart';
import '../../features/auth/domain/repositories/auth_repo.dart';
import '../../main.dart';
import '../../models/user_model.dart';
import 'local_data_manager.dart';

final userProvider = StateProvider<UserModel?>((ref) {
  ref.listenSelf((previous, next) {
    if ((previous?.id != next?.id) || (next == null)) {}
  });
  return null;
});

final isNeedToCompleteProfile = Provider.autoDispose<bool>((ref) {
  final profile = ref.watch(userProvider);
  return [
    profile?.name == null || profile?.name == "",
    profile?.email == null || profile?.email == "",
    profile?.image == null || profile?.image == "",
    profile?.phone == null || profile?.phone == "",
  ].every((e) => e);
});
final isInReviewProvider = Provider.autoDispose<bool>((ref) {
  if (ref.watch(isNeedToCompleteProfile)) {
    return false;
  } else {
    return ref.watch(userProvider)?.email != null;
  }
});
final canSubmitOrder = Provider.autoDispose<bool>((ref) {
  return ref.watch(isInReviewProvider) == false &&
      ref.watch(isNeedToCompleteProfile) == false;
});

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(userProvider)?.id;
});

final fetchUserProvider = FutureProvider.autoDispose<bool>((ref) async {
  final token = dataManager.getToken();
  if (token != null) {
    final res = await getIt<AuthRepo>().getMyProfile();
    return res.fold((error) async {
      if (error is PendingVerificationFailure) {
        ref.read(userProvider.notifier).state = dataManager.getUser();
        return true;
      }
      if (error.message == "notfound") {
        await dataManager.removeLoggedUser();
        return false;
      } else {
        print("object");
        ref.read(userProvider.notifier).state = null;
        throw error;
      }
    }, (user) async {
      ref.read(userProvider.notifier).state = user;

      // try {
      //   final uploader = FirestoreDataUploader();
      //   final userData = {
      //     "_id": user.id,
      //     "id": user.id,
      //     "phone": user.phone ?? "",
      //     "countryCode": user.countryCode ?? "",
      //     "role": user.role,
      //     "name": user.name,
      //     "email": user.email,
      //     "avatar": user.image ?? "",
      //     "isVerified": user.isVerified,
      //     "isProfileComplete": user.isProfileComplete ?? false,
      //   };
      //   await uploader.initUserDataIfNotExists(
      //     userData: userData,
      //     createChatRoom: true,
      //     createSampleMessages: true,
      //   );
      // } catch (e) {
      //   print("Error uploading user to Firestore: $e");
      // }

      return true;
    });
  } else {
    return false;
  }
});
