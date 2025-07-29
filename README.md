# Quick Request

**Quick Request** is a modern, developer-friendly HTTP client package for Flutter.  
It brings a clean, type-safe, and extensible API for making HTTP requests with minimal boilerplate code, advanced features like interceptors, JWT auto-refresh, request cancellation, caching, and more.

---

## Features

- Easy HTTP requests: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`
- Type-safe automatic JSON serialization/deserialization
- Powerful interceptors (logging, authentication, etc.)
- JWT auto-refresh support
- Global and per-request headers, query, and path parameters
- Request cancellation and timeout
- Response caching and mock support
- File upload/download with progress tracking
- Unified response model and error handling
- Short, chainable API for rapid development

---

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  quick_request: ^0.1.1
```

---

## Getting Started

Import the package:

```dart
import 'package:quick_request/quick_request.dart';
```

---

## Quick Examples

### 1. Basic GET Request

```dart
final quick = QuickRequest(baseUrl: "https://api.example.com");

final response = await quick.url("/posts").get<List<Post>>(
  fromJson: (json) => Post.fromJson(json),
  expectJsonArray: true,
);

if (!response.error) {
  print(response.data); // List<Post>
}
```

---

### 2. POST Request

```dart
final response = await quick.url("/posts").body({
  "title": "New Post",
}).post<Post>(
  fromJson: (json) => Post.fromJson(json),
);

print(response.data?.id);
```

---

### 3. PUT & PATCH Request

```dart
// PUT
await quick.url("/posts/1").body({"title": "Updated"}).put<Post>(
  fromJson: (json) => Post.fromJson(json),
);

// PATCH
await quick.url("/posts/1").body({"title": "Patched"}).patch<Post>(
  fromJson: (json) => Post.fromJson(json),
);
```

---

### 4. DELETE Request

```dart
await quick.url("/posts/1").delete<void>(
  fromJson: (_) => null,
);
```

---

### 5. Authorized Request (Bearer Token)

```dart
final token = await LocalManager().getStringValue("accessToken");
await quick
  .url("/secure-posts")
  .headers({"Authorization": "Bearer $token"})
  .get<List<Post>>(
    fromJson: (json) => Post.fromJson(json),
    expectJsonArray: true,
  );
```

---

### 6. Query & Path Parameters

```dart
// Query
await quick.url("/posts").query({"userId": "1"}).get<List<Post>>(
  fromJson: (json) => Post.fromJson(json),
  expectJsonArray: true,
);

// Path
await quick.url("/user/{id}").pathParams({"id": 5}).get<User>(
  fromJson: (json) => User.fromJson(json),
);
```

---

### 7. Request Cancellation & Timeout

```dart
final cancelToken = CancelToken();
quick.url("/slow-endpoint").cancelToken(cancelToken).get();
cancelToken.cancel(); // Cancel the request

// Timeout
await quick.url("/posts").timeout(Duration(seconds: 5)).get<List<Post>>(
  fromJson: (json) => Post.fromJson(json),
  expectJsonArray: true,
);
```

---

### 8. File Upload

```dart
final fileBytes = await File("path/to/file").readAsBytes();

await quick
  .url("/upload")
  .body({"file": fileBytes})
  .post<Map<String, dynamic>>(
    fromJson: (json) => json,
  );
```

---

### 9. Response Caching

```dart
final quick = QuickRequest(
  baseUrl: "https://api.example.com",
  cacheManager: CacheManager(),
);

await quick.url("/posts").get<List<Post>>(
  fromJson: (json) => Post.fromJson(json),
  expectJsonArray: true,
  useCache: true,
);
```

---

### 10. Error Handling

```dart
try {
  final response = await quick.url("/user/me").get<User>(
    fromJson: (json) => User.fromJson(json),
  );
} on UnauthorizedException {
  // Handle token expired
} on NetworkException {
  // Handle no connection
} catch (e) {
  // Handle other errors
}
```

---

### 11. Interceptors (Logging & JWT Refresh)

```dart
final quick = QuickRequest(
  baseUrl: "https://api.example.com",
  interceptors: [
    LoggingInterceptor(),
    JwtRefreshInterceptor(
      getAccessToken: () async => await LocalManager().getStringValue("accessToken"),
      refreshToken: () async {
        // Your refresh logic here
      },
    ),
  ],
);
```

---

### 12. With UI Feedback (e.g., using `alert_craft`)

```dart
Future<void> _fetchData() async {
  final apiRequest = QuickRequest();
  try {
    final response = await apiRequest.url('/posts/1').get<Post>(
      fromJson: (json) => Post.fromJson(json),
    );
    if (!response.error) {
      ShowAlert().showToastMessage(
        type: 1,
        title: "Success",
        description: response.data?.title ?? "",
      );
    } else {
      ShowAlert().showAlertDialog(
        type: 1,
        title: "Error",
        description: response.message ?? "Unknown error occurred",
      );
    }
  } catch (e) {
    ShowAlert().showAlertDialog(
      type: 1,
      title: "Exception",
      description: e.toString(),
    );
  }
}
```

---

## 🧩 Model Example

```dart
class Post {
  final int id;
  final String title;

  Post({required this.id, required this.title});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}
```

---

##  Response Model

All requests return a `ResponseModel<T>`:

```dart
class ResponseModel<T> {
  final T? data;
  final bool error;
  final String? message;
  final int? statusCode;

  // ...
}
```

---

## API Reference

- `QuickRequest(baseUrl, interceptors, cacheManager)`
- `.url(String path)`
- `.query(Map<String, dynamic>)`
- `.pathParams(Map<String, dynamic>)`
- `.headers(Map<String, String>)`
- `.body(dynamic)`
- `.timeout(Duration)`
- `.onProgress(ProgressCallback)`
- `.cancelToken(CancelToken)`
- `.get<T>({ fromJson, expectJsonArray, useCache })`
- `.post<T>({ fromJson, expectJsonArray })`
- `.put<T>({ fromJson, expectJsonArray })`
- `.patch<T>({ fromJson, expectJsonArray })`
- `.delete<T>({ fromJson, expectJsonArray })`

---

## License

MIT

---

## Contributing

Pull requests and feature requests are welcome!  
For major changes, please open an issue first to discuss what you would like to change.

---

**Enjoy rapid and professional API development with Quick Request!**
