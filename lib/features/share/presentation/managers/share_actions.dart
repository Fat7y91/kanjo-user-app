import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj/core/service/loading_provider.dart';
import 'package:heraj/core/service/share_service.dart';
import 'package:heraj/features/share/domain/entities/share_link_type.dart';
import 'package:heraj/main.dart';
import 'package:heraj/ui/ui.dart';

Future<void> shareItem({
  required ShareLinkType type,
  required int id,
  String? subject,
  String? text,
  WidgetRef? ref,
  String? loadingKey,
}) async {
  final key = loadingKey ?? 'share_${type.apiValue}_$id';
  ref?.read(isLoadingProvider(key).notifier).state = true;
  try {
    final result = await getIt<ShareService>().share(
      type: type,
      id: id,
      subject: subject,
      text: text,
    );
    result.fold(
      (failure) => UIHelper.showAlert(
        failure.message.isNotEmpty
            ? failure.message
            : 'Failed to share'.tr,
        type: DialogType.error,
      ),
      (_) {},
    );
  } finally {
    ref?.read(isLoadingProvider(key).notifier).state = false;
  }
}
