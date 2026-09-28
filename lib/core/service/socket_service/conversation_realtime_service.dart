import 'dart:async';
import 'dart:convert';

import 'package:heraj/core/service/local_data_manager.dart';
import 'package:heraj/core/service/socket_service/realtime_logger.dart';
import 'package:heraj/core/service/socket_service/reverb_config.dart';
import 'package:heraj/features/conversations/data/models/conversation_realtime_event_model.dart';
import 'package:pusher_reverb_flutter/pusher_reverb_flutter.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ConversationRealtimeService {
  ReverbClient? _client;
  Future<void>? _connectingFuture;
  bool _hadSuccessfulConnection = false;

  final Map<String, Channel> _channels = {};
  final Map<String, StreamSubscription<ChannelEvent>> _channelDebugSubs = {};
  final Map<String, StreamSubscription<ChannelEvent>> _eventSubs = {};
  final Map<String, String> _subscriptionChannels = {};
  final StreamController<void> _reconnectedController =
      StreamController<void>.broadcast();

  Stream<void> get onReconnected => _reconnectedController.stream;

  bool get _isConnected =>
      _client != null && _client!.connectionState == ConnectionState.connected;

  /// Vendor conversation channels are private.
  /// Service-provider conversation channels are public.
  /// `App.Models.User.*` is Laravel's private user channel.
  /// User-app order channel `customer.orders.{userId}` is private.
  /// Public catalog channel `products` is public.
  static bool isPrivateChannel(String channelName) {
    final name = channelName.trim();
    if (name.startsWith('private-') || name.startsWith('presence-')) {
      return true;
    }
    if (name == 'products' || name.startsWith('products.')) {
      return false;
    }
    if (name.startsWith('customer.orders.') ||
        name.startsWith('private-customer.orders.') ||
        name.startsWith('customer.order.') ||
        name.startsWith('private-customer.order.') ||
        name.startsWith('orders.') ||
        name.startsWith('private-orders.')) {
      return true;
    }
    if (name.contains('service-provider-conversations')) {
      return false;
    }
    if (name.contains('vendor-conversations')) {
      return true;
    }
    if (name.startsWith('App.Models.')) {
      return true;
    }
    return false;
  }

  Future<void> connectIfPossible() async {
    RealtimeLogger.d(
      'connectIfPossible() configured=${ReverbConfig.isConfigured} '
      'host=${ReverbConfig.reverbHost}:${ReverbConfig.port} '
      'tls=${ReverbConfig.useTLS} '
      'hasToken=${dataManager.getToken() != null}',
    );
    if (!ReverbConfig.isConfigured || dataManager.getToken() == null) {
      RealtimeLogger.w('connectIfPossible skipped — missing config or token');
      return;
    }
    try {
      await ensureConnected();
    } catch (error, stackTrace) {
      RealtimeLogger.e(
        'connectIfPossible failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> ensureConnected() async {
    RealtimeLogger.d(
      'ensureConnected() connected=$_isConnected '
      'state=${_client?.connectionState}',
    );
    if (!ReverbConfig.isConfigured) {
      RealtimeLogger.w('ensureConnected skipped — Reverb is not configured');
      return;
    }
    if (_isConnected) {
      RealtimeLogger.d('already connected — skip');
      return;
    }

    _connectingFuture ??= _connectUntilReady();
    try {
      await _connectingFuture;
    } finally {
      if (_isConnected ||
          _client?.connectionState == ConnectionState.error ||
          _client?.connectionState == ConnectionState.disconnected) {
        _connectingFuture = null;
      }
    }

    if (!_isConnected) {
      RealtimeLogger.e(
        'ensureConnected failed — state=${_client?.connectionState}',
      );
    } else {
      RealtimeLogger.i(
        'ensureConnected OK — state=${_client!.connectionState}',
      );
    }
  }

  Future<void> _connectUntilReady() async {
    _ensureClient();
    final client = _client!;
    RealtimeLogger.i(
      'connecting to ${ReverbConfig.reverbHost}:${ReverbConfig.port} '
      'tls=${ReverbConfig.useTLS} keyLen=${ReverbConfig.reverbAppKey.length}',
    );
    if (client.connectionState == ConnectionState.connected) {
      return;
    }

    final ready = client.onConnectionStateChange.firstWhere(
      (state) =>
          state == ConnectionState.connected ||
          state == ConnectionState.error ||
          state == ConnectionState.disconnected,
    );

    if (client.connectionState != ConnectionState.connecting &&
        client.connectionState != ConnectionState.reconnecting) {
      await client.connect();
    }

    if (client.connectionState == ConnectionState.connected) {
      return;
    }

    final state = await ready.timeout(
      const Duration(seconds: 20),
      onTimeout: () {
        RealtimeLogger.e('connection timed out after 20s');
        throw TimeoutException('Realtime connection timed out');
      },
    );

    if (state != ConnectionState.connected) {
      RealtimeLogger.e('connection ended with state: $state');
      throw StateError('Realtime connection ended with state: $state');
    }
  }

  void _ensureClient() {
    if (_client != null) {
      return;
    }

    RealtimeLogger.i(
      'creating ReverbClient authEndpoint=${ReverbConfig.authEndpoint}',
    );

    _client = ReverbClient.instance(
      host: ReverbConfig.reverbHost,
      port: ReverbConfig.port,
      appKey: ReverbConfig.reverbAppKey,
      useTLS: ReverbConfig.useTLS,
      authEndpoint: ReverbConfig.authEndpoint,
      authorizer: _authorizer,
      channelFactory: (uri) {
        RealtimeLogger.i('ws connecting $uri');
        return _LoggingWebSocketChannel.connect(
          uri,
          onIncoming: _onSocketFrame,
          onOutgoing: (message) {
            RealtimeLogger.d('WS >> $message');
          },
        );
      },
      onConnecting: () {
        RealtimeLogger.d('socket connecting...');
      },
      onConnected: (socketId) {
        RealtimeLogger.i('socket connected socketId=$socketId');
        if (_hadSuccessfulConnection) {
          RealtimeLogger.i('socket reconnected — notifying listeners');
          if (!_reconnectedController.isClosed) {
            _reconnectedController.add(null);
          }
        } else {
          _hadSuccessfulConnection = true;
        }
      },
      onReconnecting: () {
        RealtimeLogger.w('socket reconnecting...');
      },
      onDisconnected: () {
        RealtimeLogger.w('socket disconnected');
      },
      onError: (error) {
        RealtimeLogger.e('socket error', error: error);
      },
    );
  }

  void _onSocketFrame(dynamic message) {
    RealtimeLogger.d('WS << $message');
    final json = _socketJson(message);
    if (json == null) return;

    final event = json['event']?.toString() ?? '';
    if (event == 'pusher:error' ||
        event == 'pusher:subscription_error' ||
        event == 'pusher_internal:subscription_error') {
      RealtimeLogger.e('WS error event=$event data=${json['data']}');
      return;
    }

    if (event == 'pusher_internal:subscription_succeeded' ||
        event == 'pusher:subscription_succeeded') {
      final channelName = json['channel']?.toString() ?? '';
      if (channelName.isEmpty) return;
      final channel = _channels[channelName] ?? _client?.getChannel(channelName);
      channel?.handleSubscriptionSucceeded();
      RealtimeLogger.i('WS subscription succeeded channel=$channelName');
    }
  }

  Future<Map<String, String>> _authorizer(
    String channelName,
    String socketId,
  ) async {
    final token = dataManager.getToken()?.trim() ?? '';
    final hasToken = token.isNotEmpty;
    RealtimeLogger.i(
      'authorizing channel=$channelName '
      'authChannel=$channelName'
      'socketId=$socketId hasToken=$hasToken',
    );
    return {
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      if (hasToken) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> subscribeToChannel({
    required String subscriptionKey,
    required String channelName,
    required String eventName,
    required void Function(ChatRealtimePayload event) onEvent,
    bool? isPrivate,
  }) async {
    await subscribeToRawEvents(
      subscriptionKey: subscriptionKey,
      channelName: channelName,
      eventNames: [eventName],
      isPrivate: isPrivate,
      onEvent: (actualEvent, data) {
        final chat = ChatRealtimePayload.tryParse({
              ...data,
              'event': actualEvent,
            }) ??
            ChatRealtimePayload.tryParse(data);
        if (chat == null) {
          RealtimeLogger.w(
            'ignored malformed chat payload key=$subscriptionKey '
            'event=$actualEvent data=$data',
          );
          return;
        }
        RealtimeLogger.i(
          'APPLY $actualEvent conversationId='
          '${chat.conversationJson['id']} messageId=${chat.message.id}',
        );
        onEvent(chat);
      },
    );
  }

  /// Subscribe to one or more Laravel Echo events on a public/private channel.
  /// [onEvent] receives the normalized event name and decoded JSON payload.
  Future<void> subscribeToRawEvents({
    required String subscriptionKey,
    required String channelName,
    required List<String> eventNames,
    required void Function(String eventName, Map<String, dynamic> data) onEvent,
    bool? isPrivate,
  }) async {
    final private = isPrivate ?? isPrivateChannel(channelName);
    final resolvedChannelName = private
        ? _privateChannelName(channelName)
        : _publicChannelName(channelName);
    final expectedEvents =
        eventNames.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (resolvedChannelName.isEmpty || expectedEvents.isEmpty) {
      RealtimeLogger.w(
        'subscribe skipped key=$subscriptionKey '
        'channel="$channelName" events=$eventNames private=$private',
      );
      return;
    }

    await ensureConnected();
    final client = _client;
    if (client == null || !_isConnected) {
      RealtimeLogger.e(
        'subscribe before connected key=$subscriptionKey '
        'channel=$resolvedChannelName events=$expectedEvents',
      );
      return;
    }

    await unsubscribeByKey(subscriptionKey);

    final isNew = !_channels.containsKey(resolvedChannelName);
    Channel channel;
    try {
      channel = _channels.putIfAbsent(resolvedChannelName, () {
        RealtimeLogger.i(
          'subscribing ${private ? 'private' : 'public'} '
          'channel=$resolvedChannelName',
        );
        final Channel newChannel = private
            ? client.subscribeToPrivateChannel(resolvedChannelName)
            : client.subscribeToChannel(resolvedChannelName);
        newChannel.addStateListener((state) {
          RealtimeLogger.i(
            'channel state channel=$resolvedChannelName -> $state',
          );
        });
        if (newChannel.state == ChannelState.unsubscribed) {
          unawaited(
            newChannel.subscribe().then((_) {
              RealtimeLogger.i(
                'subscribe() done channel=$resolvedChannelName '
                'state=${newChannel.state}',
              );
            }).catchError((Object error, StackTrace stack) {
              RealtimeLogger.e(
                'subscribe() failed channel=$resolvedChannelName',
                error: error,
                stackTrace: stack,
              );
            }),
          );
        } else {
          RealtimeLogger.i(
            'subscribe already in flight channel=$resolvedChannelName '
            'state=${newChannel.state}',
          );
        }
        _channelDebugSubs[resolvedChannelName] = newChannel.stream.listen(
          (event) {
            RealtimeLogger.d(
              'RAW channel=$resolvedChannelName event=${event.eventName} '
              'data=${event.data}',
            );
          },
          onError: (Object error, StackTrace stack) {
            RealtimeLogger.e(
              'channel stream error channel=$resolvedChannelName',
              error: error,
              stackTrace: stack,
            );
          },
        );
        return newChannel;
      });
    } catch (error, stack) {
      RealtimeLogger.e(
        'subscribe threw channel=$resolvedChannelName',
        error: error,
        stackTrace: stack,
      );
      return;
    }

    if (isNew) {
      RealtimeLogger.d(
        'listening for events=$expectedEvents on $resolvedChannelName',
      );
    } else {
      RealtimeLogger.d(
        'reusing channel=$resolvedChannelName for events=$expectedEvents '
        'state=${channel.state}',
      );
    }

    _subscriptionChannels[subscriptionKey] = resolvedChannelName;
    _eventSubs[subscriptionKey] = channel.stream.listen((event) {
      if (event.eventName.startsWith('pusher')) return;
      final matched = expectedEvents.any(
        (expected) => _matchesEvent(event.eventName, expected),
      );
      if (!matched) return;

      final data = parseRealtimeJsonMap(event.data);
      if (data == null) {
        RealtimeLogger.w(
          'ignored non-json payload key=$subscriptionKey '
          'event=${event.eventName} data=${event.data}',
        );
        return;
      }

      RealtimeLogger.i(
        'APPLY ${event.eventName} key=$subscriptionKey '
        'channel=$resolvedChannelName',
      );
      onEvent(event.eventName, data);
    });
  }

  /// Decode Laravel Echo / Pusher event `data` (map or JSON string).
  static Map<String, dynamic>? parseRealtimeJsonMap(dynamic raw) {
    final map = _socketJson(raw);
    if (map == null) return null;
    final nested = map['data'];
    if (nested is String && nested.trim().isNotEmpty) {
      final decoded = _socketJson(nested);
      if (decoded != null) return decoded;
    }
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }
    return map;
  }

  Future<void> unsubscribeByKey(String subscriptionKey) async {
    RealtimeLogger.d('unsubscribe key=$subscriptionKey');
    await _eventSubs.remove(subscriptionKey)?.cancel();

    final channelName = _subscriptionChannels.remove(subscriptionKey);
    if (channelName == null) {
      return;
    }
    if (_subscriptionChannels.containsValue(channelName)) {
      RealtimeLogger.d(
        'keep channel=$channelName — still used by another subscription',
      );
      return;
    }

    await _channelDebugSubs.remove(channelName)?.cancel();
    _channels.remove(channelName);
    try {
      _client?.unsubscribeFromChannel(channelName);
    } catch (error, stack) {
      RealtimeLogger.e(
        'unsubscribe failed channel=$channelName',
        error: error,
        stackTrace: stack,
      );
    }
    RealtimeLogger.i('unsubscribed channel=$channelName');
  }

  Future<void> disconnect() async {
    RealtimeLogger.i('disconnect() — clearing ${_channels.length} channels');
    for (final sub in _eventSubs.values) {
      await sub.cancel();
    }
    _eventSubs.clear();
    _subscriptionChannels.clear();

    for (final sub in _channelDebugSubs.values) {
      await sub.cancel();
    }
    _channelDebugSubs.clear();

    for (final channelName in _channels.keys.toList()) {
      try {
        _client?.unsubscribeFromChannel(channelName);
      } catch (_) {}
    }
    _channels.clear();

    _connectingFuture = null;
    _hadSuccessfulConnection = false;
    _client?.disconnect();
    _client = null;
  }

  bool _matchesEvent(String actual, String expected) {
    String normalize(String value) {
      var name = value.trim();
      if (name.startsWith('.')) name = name.substring(1);
      return name.toLowerCase();
    }

    final a = normalize(actual);
    final e = normalize(expected);
    return a == e || a.endsWith('.$e') || e.endsWith('.$a');
  }

  String _privateChannelName(String channelName) {
    final name = channelName.trim();
    if (name.isEmpty) return '';
    if (name.startsWith('private-')) return name;
    return 'private-$name';
  }

  String _publicChannelName(String channelName) {
    final name = channelName.trim();
    if (name.isEmpty) return '';
    if (name.startsWith('private-')) {
      return name.substring('private-'.length);
    }
    return name;
  }
}

Map<String, dynamic>? _socketJson(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return null;
}

class _LoggingWebSocketChannel extends StreamChannelMixin
    implements WebSocketChannel {
  _LoggingWebSocketChannel._(
    this._inner, {
    required this.onIncoming,
    required void Function(dynamic message) onOutgoing,
  }) : _outgoingLogger = onOutgoing {
    _inner.stream.listen(
      (message) {
        onIncoming(message);
        if (!_incoming.isClosed) {
          _incoming.add(message);
        }
      },
      onError: (Object error, StackTrace stack) {
        if (!_incoming.isClosed) {
          _incoming.addError(error, stack);
        }
      },
      onDone: () {
        if (!_incoming.isClosed) {
          _incoming.close();
        }
      },
    );
  }

  factory _LoggingWebSocketChannel.connect(
    Uri uri, {
    required void Function(dynamic message) onIncoming,
    required void Function(dynamic message) onOutgoing,
  }) {
    final inner = IOWebSocketChannel.connect(uri);
    return _LoggingWebSocketChannel._(
      inner,
      onIncoming: onIncoming,
      onOutgoing: onOutgoing,
    );
  }

  final WebSocketChannel _inner;
  final void Function(dynamic message) onIncoming;
  final void Function(dynamic message) _outgoingLogger;
  final StreamController<dynamic> _incoming =
      StreamController<dynamic>.broadcast();

  @override
  Stream<dynamic> get stream => _incoming.stream;

  @override
  WebSocketSink get sink => _LoggingWebSocketSink(_inner.sink, _outgoingLogger);

  @override
  int? get closeCode => _inner.closeCode;

  @override
  String? get closeReason => _inner.closeReason;

  @override
  String? get protocol => _inner.protocol;

  @override
  Future<void> get ready => _inner.ready;
}

class _LoggingWebSocketSink implements WebSocketSink {
  _LoggingWebSocketSink(this._inner, this._onSend);

  final WebSocketSink _inner;
  final void Function(dynamic data) _onSend;

  @override
  void add(event) {
    _onSend(event);
    _inner.add(event);
  }

  @override
  void addError(error, [StackTrace? stackTrace]) {
    _inner.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream stream) => _inner.addStream(stream);

  @override
  Future close([int? closeCode, String? closeReason]) {
    return _inner.close(closeCode, closeReason);
  }

  @override
  Future get done => _inner.done;
}
