import 'package:envied/envied.dart';
import 'package:flutter/foundation.dart';
import 'package:heraj/config/api_path.dart';

part 'reverb_config.g.dart';

@Envied(path: 'env/.env', requireEnvFile: true,obfuscate: kReleaseMode)
abstract class ReverbConfig {
  @EnviedField(varName: 'REVERB_APP_KEY', obfuscate: true)
  static final String reverbAppKey = _strip(_ReverbConfig.reverbAppKey);

  @EnviedField(varName: 'REVERB_HOST', obfuscate: true)
  static final String reverbHost = _strip(_ReverbConfig.reverbHost);

  @EnviedField(varName: 'REVERB_PORT', obfuscate: true)
  static final String reverbPort = _strip(_ReverbConfig.reverbPort);

  @EnviedField(varName: 'REVERB_SCHEME', obfuscate: true)
  static final String reverbScheme = _strip(_ReverbConfig.reverbScheme);

  static bool get useTLS => reverbScheme.toLowerCase() == 'https';

  static int get port => int.tryParse(reverbPort) ?? (useTLS ? 443 : 80);

  static bool get isConfigured {
    return reverbAppKey.isNotEmpty &&
        reverbAppKey != 'replace_with_reverb_app_key' &&
        reverbHost.isNotEmpty;
  }

  static String get authEndpoint =>
      '${ApiPath.sharePath}${ApiPath.broadcastingAuth}';

  static String _strip(String value) =>
      value.trim().replaceAll('"', '').replaceAll("'", '');
}
