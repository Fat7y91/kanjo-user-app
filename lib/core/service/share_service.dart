import 'package:fpdart/fpdart.dart';
import 'package:heraj/core/errors/failure.dart';
import 'package:heraj/features/share/domain/entities/create_share_link_params.dart';
import 'package:heraj/features/share/domain/entities/share_link_type.dart';
import 'package:heraj/features/share/domain/use_case/create_share_link_use_case.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService({required this.createShareLinkUseCase});

  final CreateShareLinkUseCase createShareLinkUseCase;

  Future<Either<Failure, void>> share({
    required ShareLinkType type,
    required int id,
    String? subject,
    String? text,
  }) async {
    final result = await createShareLinkUseCase(
      CreateShareLinkParams(type: type, id: id),
    );

    return result.fold(
      Left.new,
      (link) async {
        await SharePlus.instance.share(
          ShareParams(
            text: text ?? link.url,
            subject: subject,
          ),
        );
        return const Right(null);
      },
    );
  }
}
