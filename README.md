# Quick Request

The `quick_request` Flutter package allows you to make HTTP requests quickly and easily. Using the `http` package, you can perform API requests in a simple and effective manner.

## Features

- Easy HTTP requests (GET, POST, PUT, PATCH, DELETE)
- `ResponseModel` class for handling responses
- Automatic encoding and decoding of JSON data

## Usage

##### GET Request

```dart
  Future<ResponseModel> fetchPosts() async {
  return await QuickRequest().request(
    url: "https://api.example.com/posts",
    requestMethod: RequestMethod.GET,
  );
}
```

##### POST Request

```dart
  Future<ResponseModel> createPost(Map<String, dynamic> data) async {
  return await QuickRequest().request(
    url: "https://api.example.com/posts",
    body: data,
    requestMethod: RequestMethod.POST,
  );
}
```

##### PUT Request

```dart
  Future<ResponseModel> updatePost(int id, Map<String, dynamic> data) async {
  return await QuickRequest().request(
    url: "https://api.example.com/posts/$id",
    body: data,
    requestMethod: RequestMethod.PUT,
  );
}
```

##### DELETE Request

```dart
  Future<ResponseModel> deletePost(int id) async {
  return await QuickRequest().request(
    url: "https://api.example.com/posts/$id",
    requestMethod: RequestMethod.DELETE,
  );
}

```

##### PATCH Request

```dart
  Future<ResponseModel> patchPost(int id, Map<String, dynamic> data) async {
  return await QuickRequest().request(
    url: "https://api.example.com/posts/$id",
    body: data,
    requestMethod: RequestMethod.PATCH,
  );
}
```

##### Authorized Request

```dart
  Future<ResponseModel> fetchSecurePosts() async {
  String? token = LocalManager().getStringValue(LocalManagerKeys.accessToken);
  return await QuickRequest().request(
    url: "https://api.example.com/secure-posts",
    bearerToken: token,
    requestMethod: RequestMethod.GET,
  );
}
```

##### GET Request with Query Parameters

```dart
  Future<ResponseModel> fetchPostsWithQueryParameters() async {
  return await QuickRequest().request(
    url: "https://api.example.com/posts",
    queryParameters: {
      "userId": "1",
    },
    requestMethod: RequestMethod.GET,
  );
}

```

##### Example PATCH Request

```dart
  Future<ResponseModel> patchPostExample(int postId, String newTitle) async {
  return await QuickRequest().request(
    url: "https://api.example.com/posts/$postId",
    body: {"title": newTitle},
    requestMethod: RequestMethod.PATCH,
  );
}

```

##### with alert_craft usage

```dart
  Future<void> _fetchData() async {
    final apiRequest = QuickRequest();
    try {
      final response = await apiRequest.request(
        url: 'https://api.example.com/posts/1',
        requestMethod: RequestMethod.GET,
      );
      if (!response.error) {
        setState(() {
          
          ShowAlert().showToastMessage(type: 1, title: "successful", description: "response.data");
        });
      } else {
        setState(() {
          ShowAlert().showAlertDialog(type: 1, title: "error", description: "response.message");
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Exception: $e';
      });
    }
  }

```

## Installation

To add the `quick_request` package to your project, include the following line in your `pubspec.yaml` file:

```yaml
dependencies:
  quick_request: ^0.0.1
