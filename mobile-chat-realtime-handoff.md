# Mobile Chat Realtime Handoff

## Purpose

This file is for mobile developers integrating pharmacy chat realtime on:

- user mobile application
- pharmacy vendor mobile application

Important:

- mobile clients do not emit websocket chat events themselves
- mobile clients send messages through API
- server broadcasts `.message.created`
- mobile clients only subscribe, receive, render, and sync

## Scope Rules

Chat is allowed only between:

- user
- pharmacy vendor

Not allowed:

- non-pharmacy vendor chat

## Reverb Basics

Use Laravel Echo compatible client with Reverb / Pusher protocol.

Needed config values:

- `REVERB_APP_KEY`
- `REVERB_HOST`
- `REVERB_PORT`
- `REVERB_SCHEME`

The event name to listen for is:

- `.message.created`

## Channels To Subscribe

### User App

Subscribe to:

- `private-App.Models.User.{userId}`
- `private-vendor-conversations.{conversationId}`

Why:

- user private channel updates conversation list and unread state
- conversation channel updates currently open chat screen

### Vendor Mobile App

Subscribe to:

- `private-vendor-conversations.vendor.{vendorId}`
- `private-vendor-conversations.{conversationId}`

Why:

- vendor inbox channel updates vendor conversation list and unread state
- conversation channel updates currently open chat screen

## Channel Authorization

Private channels require auth through:

- `POST /broadcasting/auth`

The authenticated user must match:

- `App.Models.User.{userId}` -> same authenticated user id
- `vendor-conversations.{conversationId}` -> authenticated participant of that conversation
- `vendor-conversations.vendor.{vendorId}` -> authenticated pharmacy vendor owner of that vendor id

If ids are wrong, auth returns `403`.

## Event To Listen For

Listen to:

- `.message.created`

Payload shape:

```json
{
  "event": "message.created",
  "conversation": {
    "id": 12,
    "vendor_id": 4,
    "vendor_name": "Pharmacy Name",
    "vendor_slug": "pharmacy-name",
    "user_id": 25,
    "user_name": "Customer Name",
    "status": "open",
    "last_message_at": "2026-06-22T14:00:00+00:00",
    "vendor_has_unread": true,
    "user_has_unread": false,
    "vendor_last_read_at": null,
    "user_last_read_at": "2026-06-22T13:58:00+00:00",
    "vendor_last_read_message_id": null,
    "user_last_read_message_id": 55,
    "latest_message_id": 56,
    "websocket": {
      "channel": "vendor-conversations.12",
      "event": "message.created"
    }
  },
  "message": {
    "id": 56,
    "sender_role": "customer",
    "sender_user_id": 25,
    "message_type": "text",
    "body": "Hello",
    "image": null,
    "meta": null,
    "created_at": "2026-06-22T14:00:00+00:00",
    "websocket_event": "message.created"
  }
}
```

## Keys Mobile Should Read

Always read:

- `event`
- `conversation.id`
- `conversation.latest_message_id`
- `conversation.last_message_at`
- `conversation.vendor_has_unread`
- `conversation.user_has_unread`
- `message.id`
- `message.sender_role`
- `message.sender_user_id`
- `message.message_type`
- `message.body`
- `message.image`
- `message.meta`
- `message.created_at`

Useful extra keys:

- `conversation.vendor_id`
- `conversation.vendor_name`
- `conversation.vendor_slug`
- `conversation.user_id`
- `conversation.user_name`
- `conversation.vendor_last_read_message_id`
- `conversation.user_last_read_message_id`

## Message Type Handling

### `text`

Render as normal chat bubble.

### `image`

Render image message from:

- `message.image.url`
- `message.image.file_name`

Current image shape:

```json
{
  "url": "/chat/conversations/12/messages/56/image",
  "file_name": "uuid-file-name.jpg"
}
```

Notes:

- `url` is an authenticated chat-media endpoint, not a public storage path
- mobile should load this URL with the same auth context used for API requests
- `body` may be `null`
- or `body` may contain optional caption text

### `pharmacy_quote`

Render quote UI from:

- `message.meta.items`
- `message.meta.total_price`
- `message.meta.currency`

Suggested item shape:

```json
{
  "items": [
    { "name": "Panadol Extra", "quantity": 2 }
  ],
  "total_price": 150,
  "currency": "EGP"
}
```

### `pharmacy_quote_accepted`

Render as a system status message.

Optional metadata:

- `message.meta.quote_message_id`

## APIs Mobile Will Use

### User App APIs

- start/find conversation:
  - `POST /api/v1/vendors/{vendor}/conversations`
- list conversations:
  - `GET /api/v1/conversations`
- get messages:
  - `GET /api/v1/conversations/{conversation}/messages`
- send text:
  - `POST /api/v1/conversations/{conversation}/messages`
- send image or text + image:
  - `POST /api/v1/conversations/{conversation}/messages`
- mark read:
  - `POST /api/v1/conversations/{conversation}/read`
- accept quote:
  - `POST /api/v1/conversations/{conversation}/messages/{message}/accept-quote`

### Vendor Mobile APIs

- list conversations:
  - `GET /api/v1/vendor/conversations`
- get messages:
  - `GET /api/v1/vendor/conversations/{conversation}/messages`
- send text:
  - `POST /api/v1/vendor/conversations/{conversation}/messages`
- send image or text + image:
  - `POST /api/v1/vendor/conversations/{conversation}/messages`
- send quote:
  - `POST /api/v1/vendor/conversations/{conversation}/quote`
- mark read:
  - `POST /api/v1/vendor/conversations/{conversation}/read`

## API Realtime Helpers

List endpoints return subscription metadata:

### User list

- `GET /api/v1/conversations`

Returns:

- `data.subscriptions.user.channel`
- `data.subscriptions.user.event`
- `data.sync.strategy`
- `data.unread_conversation_ids`

### Vendor list

- `GET /api/v1/vendor/conversations`

Returns:

- `data.subscriptions.inbox.channel`
- `data.subscriptions.inbox.event`
- `data.sync.strategy`

### Messages endpoints

User and vendor messages endpoints return:

- `data.subscriptions.conversation.channel`
- `data.subscriptions.conversation.event`
- `data.sync.strategy`
- `data.sync.requested_after_message_id`
- `data.sync.latest_message_id`

## Reconnect Strategy

Use `after_message_id` recovery.

Mobile should:

1. store the latest received `message.id` or `conversation.latest_message_id`
2. on reconnect or app resume, fetch:
   - `GET /messages?after_message_id={lastSeenMessageId}`
3. append the missing messages
4. update local conversation state from API response

This avoids depending only on live socket delivery.

## Read / Unread Rules

### User side

- vendor message makes `conversation.user_has_unread = true`
- fetching user messages endpoint marks conversation read
- explicit user read endpoint also marks conversation read

### Vendor side

- user message makes `conversation.vendor_has_unread = true`
- fetching vendor messages endpoint marks conversation read
- explicit vendor read endpoint also marks conversation read

## Mobile Integration Notes

- subscribe after login is ready
- subscribe after real ids are known
- do not subscribe with placeholder ids
- conversation screen should deduplicate by `message.id`
- conversation list should update preview, unread state, and order from the event payload
- message send success response also includes `realtime`, but UI should still trust the websocket event as the shared live contract

## Minimal Client Flow

### User app

1. call `GET /api/v1/conversations`
2. subscribe to `data.subscriptions.user.channel`
3. open a conversation
4. call `GET /api/v1/conversations/{conversation}/messages`
5. subscribe to `data.subscriptions.conversation.channel`
6. on `.message.created`, update list and open thread

### Vendor app

1. call `GET /api/v1/vendor/conversations`
2. subscribe to `data.subscriptions.inbox.channel`
3. open a conversation
4. call `GET /api/v1/vendor/conversations/{conversation}/messages`
5. subscribe to `data.subscriptions.conversation.channel`
6. on `.message.created`, update list and open thread

## What Mobile Does Not Need To Emit

Mobile client does not need to emit:

- message created event
- unread event
- list refresh event

Only the server emits realtime chat events.

## Send Request Format

For image sends, use `multipart/form-data`.

Supported combinations:

- `body` only
- `image` only
- `body` + `image`

Current send fields:

- `body`: optional string, max 5000
- `image`: optional image file

Current image validation:

- required only when `body` is missing
- allowed mimes: `jpg`, `jpeg`, `png`, `webp`
- max size: controlled by backend config

## Security Notes

- `message.image.url` is participant-only
- user can open image only for their own conversation
- pharmacy vendor can open image only for their own conversation
- non-pharmacy vendors cannot access chat media
- do not try to build storage URLs on the client
- always trust the `image.url` returned by API or websocket payload
