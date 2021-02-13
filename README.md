# hf_retry

A plugin to enhance user experience during network downtime. 

- Shows placeholder image in place of `NetworkImage` when network is unavailable
- Retries and fetches `NetworkImage` as soon as the device is connected to network

Just use `NetworkImageWithRetry` in place of `NetworkImage`

### Example
```dart
Image(
  image: NetworkImageWithRetry('http://example.com/avatars/123.jpg'),
  errorBuilder: (context, _, __) {
    return FlutterLogo(
      size: 200,
    );
  },
),
```
