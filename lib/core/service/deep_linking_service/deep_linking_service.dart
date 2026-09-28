import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:heraj/features/share/domain/entities/share_link_resolve_entity.dart';
import 'package:heraj/features/share/domain/use_case/resolve_share_link_use_case.dart';

class DeepLinkService {
  DeepLinkService({required this.resolveShareLinkUseCase});

  final ResolveShareLinkUseCase resolveShareLinkUseCase;
  final AppLinks _appLinks = AppLinks();

  String? _pendingReference;
  ShareLinkResolveEntity? _resolvedTarget;
  bool _appReady = false;
  bool _handlingWarmLink = false;
  String? _lastHandledReference;

  ShareLinkResolveEntity? get resolvedTarget => _resolvedTarget;

  bool get hasPendingShare =>
      (_pendingReference != null && _pendingReference!.isNotEmpty) ||
      _resolvedTarget != null;

  Future<void> init({
    void Function(ShareLinkResolveEntity resolved)? onResolvedWhileRunning,
  }) async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      _captureUri(initialUri);
    } catch (e) {
      if (kDebugMode) {
        print('DeepLinkService initial link error: $e');
      }
    }

    _appLinks.uriLinkStream.listen(
      (uri) async {
        final reference = extractShareReference(uri);
        if (reference == null || reference.isEmpty) return;

        // Cold start: capture only; splash resolves after navigation is ready.
        if (!_appReady) {
          _captureUri(uri);
          return;
        }

        // Ignore duplicate warm events for the same reference.
        if (_handlingWarmLink || _lastHandledReference == reference) {
          return;
        }

        _pendingReference = reference;
        _resolvedTarget = null;
        _handlingWarmLink = true;
        try {
          final resolved = await resolvePending();
          if (resolved != null) {
            _lastHandledReference = reference;
            onResolvedWhileRunning?.call(resolved);
          }
        } finally {
          _handlingWarmLink = false;
        }
      },
      onError: (Object error) {
        if (kDebugMode) {
          print('DeepLinkService stream error: $error');
        }
      },
    );
  }

  void markAppReady() {
    _appReady = true;
  }

  void _captureUri(Uri? uri) {
    final reference = extractShareReference(uri);
    if (reference == null || reference.isEmpty) return;
    _pendingReference = reference;
    _resolvedTarget = null;
  }

  static String? extractShareReference(Uri? uri) {
    if (uri == null) return null;

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return null;

    if (segments.first == 's' && segments.length >= 2) {
      return segments[1];
    }

    final path = uri.path;
    const prefix = '/s/';
    if (path.startsWith(prefix) && path.length > prefix.length) {
      return path.substring(prefix.length).split('/').first;
    }

    return null;
  }

  Future<ShareLinkResolveEntity?> resolvePending() async {
    if (_resolvedTarget != null) return _resolvedTarget;

    final reference = _pendingReference;
    if (reference == null || reference.isEmpty) return null;

    final result = await resolveShareLinkUseCase(reference);
    return result.fold(
      (failure) {
        if (kDebugMode) {
          print('Share link resolve failed: ${failure.message}');
        }
        _pendingReference = null;
        return null;
      },
      (resolved) {
        _resolvedTarget = resolved;
        _pendingReference = null;
        return resolved;
      },
    );
  }

  void clear() {
    _pendingReference = null;
    _resolvedTarget = null;
    _lastHandledReference = null;
  }
}
