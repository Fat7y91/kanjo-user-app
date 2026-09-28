import 'share_link_type.dart';

class CreateShareLinkParams {
  const CreateShareLinkParams({
    required this.type,
    required this.id,
  });

  final ShareLinkType type;
  final int id;
}
