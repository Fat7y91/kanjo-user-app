import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/create_share_link_params.dart';
import '../entities/share_link_entity.dart';
import '../repo/share_links_repo.dart';

class CreateShareLinkUseCase {
  CreateShareLinkUseCase({required this.shareLinksRepo});

  final ShareLinksRepo shareLinksRepo;

  Future<Either<Failure, ShareLinkEntity>> call(CreateShareLinkParams params) {
    return shareLinksRepo.createShareLink(params);
  }
}
