# hr_retry

A plugin to enhance user experience during network downtime. 

- Shows placeholder image in place of `NetworkImage` when there is no network is unawailable
- Retries and fetches `NetworkImage` as soon as the device is connected to the internet

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
