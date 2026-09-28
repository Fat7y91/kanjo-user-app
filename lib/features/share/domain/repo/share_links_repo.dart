import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/create_share_link_params.dart';
import '../../domain/entities/share_link_entity.dart';
import '../../domain/entities/share_link_resolve_entity.dart';

abstract class ShareLinksRepo {
  Future<Either<Failure, ShareLinkEntity>> createShareLink(
    CreateShareLinkParams params,
  );

  Future<Either<Failure, ShareLinkResolveEntity>> resolveShareLink(
    String reference,
  );
}
