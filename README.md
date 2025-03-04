# Quick Request

The `quick_request` Flutter package allows you to make HTTP requests quickly and easily. Using the `http` package, you can perform API requests in a simple and effective manner.

## Features

- Easy HTTP requests (GET, POST, PUT, PATCH, DELETE)
- `ResponseModel` class for handling responses
- Automatic encoding and decoding of JSON data

## Usage

##### GET Request

```dart
  Future<ResponseModel<List<Post>>> fetchPosts() async {
  return await QuickRequest().request<List<Post>>(
    url: "https://api.example.com/posts",
    fromJson: (json) => Post.fromJson(json),
  );
}
```

##### POST Request

```dart
  Future<ResponseModel<Post>> createPost(Map<String, dynamic> data) async {
  return await QuickRequest().request<Post>(
    url: "https://api.example.com/posts",
    body: data,
    requestMethod: RequestMethod.POST,
    fromJson: (json) => Post.fromJson(json),
  );
}

```

##### PUT Request

```dart
  Future<ResponseModel<Post>> updatePost(int id, Map<String, dynamic> data) async {
  return await QuickRequest().request<Post>(
    url: "https://api.example.com/posts/$id",
    body: data,
    requestMethod: RequestMethod.PUT,
    fromJson: (json) => Post.fromJson(json),
  );
}

```

##### DELETE Request

```dart
  Future<ResponseModel<void>> deletePost(int id) async {
  return await QuickRequest().request<void>(
    url: "https://api.example.com/posts/$id",
    requestMethod: RequestMethod.DELETE,
    fromJson: (_) => null, // DELETE için genelde dönüşüm gerekmez
  );
}


```

##### PATCH Request

```dart
  Future<ResponseModel<Post>> patchPost(int id, Map<String, dynamic> data) async {
  return await QuickRequest().request<Post>(
    url: "https://api.example.com/posts/$id",
    body: data,
    requestMethod: RequestMethod.PATCH,
    fromJson: (json) => Post.fromJson(json),
  );
}

```

##### Authorized Request

```dart
  Future<ResponseModel<List<Post>>> fetchSecurePosts() async {
  String? token = LocalManager().getStringValue(LocalManagerKeys.accessToken);
  return await QuickRequest().request<List<Post>>(
    url: "https://api.example.com/secure-posts",
    bearerToken: token,
    fromJson: (json) => Post.fromJson(json),
  );
}

```

##### GET Request with Query Parameters

```dart
  Future<ResponseModel<List<Post>>> fetchPostsWithQueryParameters() async {
  return await QuickRequest().request<List<Post>>(
    url: "https://api.example.com/posts",
    queryParameters: {
      "userId": "1",
    },
    fromJson: (json) => Post.fromJson(json),
  );
}


```

##### Example PATCH Request

```dart
  Future<ResponseModel<Post>> patchPostExample(int postId, String newTitle) async {
  return await QuickRequest().request<Post>(
    url: "https://api.example.com/posts/$postId",
    body: {"title": newTitle},
    requestMethod: RequestMethod.PATCH,
    fromJson: (json) => Post.fromJson(json),
  );
}


```

##### with alert_craft usage

```dart
  Future<void> _fetchData() async {
  final apiRequest = QuickRequest();
  try {
    final response = await apiRequest.request<Post>(
      url: 'https://api.example.com/posts/1',
      fromJson: (json) => Post.fromJson(json),
    );
    if (!response.error!) {
      setState(() {
        ShowAlert().showToastMessage(
          type: 1,
          title: "Başarılı",
          description: response.data?.title ?? "",
        );
      });
    } else {
      setState(() {
        ShowAlert().showAlertDialog(
          type: 1,
          title: "Hata",
          description: response.message ?? "Bilinmeyen bir hata oluştu",
        );
      });
    }
  } catch (e) {
    setState(() {
      ShowAlert().showAlertDialog(
        type: 1,
        title: "Exception",
        description: e.toString(),
      );
    });
  }
}


```

## Örnek Model

Aşağıda bir Post sınıfı örneği verilmiştir:

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

## Installation

To add the `quick_request` package to your project, include the following line in your `pubspec.yaml` file:

```yaml
dependencies:
  quick_request: ^0.0.1
