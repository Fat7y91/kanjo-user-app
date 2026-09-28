import 'package:url_launcher/url_launcher_string.dart';

launchInWhats(String phone) {
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  launchUrlString(
    """https://wa.me/2$phone?${encodeQueryParameters({
      'text': ''
    })}""",
    mode: LaunchMode.externalApplication,
  );
}