import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/share_link_resolve_entity.dart';
import '../repo/share_links_repo.dart';

class ResolveShareLinkUseCase {
  ResolveShareLinkUseCase({required this.shareLinksRepo});

  final ShareLinksRepo shareLinksRepo;

  Future<Either<Failure, ShareLinkResolveEntity>> call(String reference) {
    return shareLinksRepo.resolveShareLink(reference);
  }
}
