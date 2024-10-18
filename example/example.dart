import 'package:flutter/material.dart';
import 'package:quick_request/request.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Request Example', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Gelen yanıtı ekranda göstermek için kullanılacak bir değişken
  String _responseMessage = 'No data fetched yet';

  @override
  void initState() {
    super.initState();
  }

  /// API'ye POST isteği gönderir (veri ekleme).
  Future<void> _createData() async {
    final apiRequest = QuickRequest();
    try {
      final response = await apiRequest.request(
        url: 'https://jsonplaceholder.typicode.com/posts', // API URL'si (POST)
        requestMethod: RequestMethod.POST,
        body: {
          'title': 'New Post',
          'body': 'This is a new post created with POST method',
          'userId': 1,
        },
      );

      if (!response.error!) {
        setState(() {
          _responseMessage = 'POST Success: ${response.data}';
        });
      } else {
        setState(() {
          _responseMessage = 'POST Error: ${response.message}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'POST Exception: $e';
      });
    }
  }

  /// API'ye PUT isteği gönderir (var olan veriyi güncelleme).
  Future<void> _updateData() async {
    final apiRequest = QuickRequest();
    try {
      final response = await apiRequest.request(
        url: 'https://jsonplaceholder.typicode.com/posts/1', // API URL'si (PUT)
        requestMethod: RequestMethod.PUT,
        body: {
          'id': 1,
          'title': 'Updated Post',
          'body': 'This post is updated with PUT method',
          'userId': 1,
        },
      );

      if (!response.error!) {
        setState(() {
          _responseMessage = 'PUT Success: ${response.data}';
        });
      } else {
        setState(() {
          _responseMessage = 'PUT Error: ${response.message}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'PUT Exception: $e';
      });
    }
  }

  /// API'ye DELETE isteği gönderir (veri silme).
  Future<void> _deleteData() async {
    final apiRequest = QuickRequest();
    try {
      final response = await apiRequest.request(
        url: 'https://jsonplaceholder.typicode.com/posts/1', // API URL'si (DELETE)
        requestMethod: RequestMethod.DELETE,
      );

      if (!response.error!) {
        setState(() {
          _responseMessage = 'DELETE Success: ${response.data}';
        });
      } else {
        setState(() {
          _responseMessage = 'DELETE Error: ${response.message}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'DELETE Exception: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Request Example'), // Uygulama başlığı
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _responseMessage, // API'den gelen yanıt burada gösteriliyor
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createData, // POST isteği için
                child: const Text('Send POST Request'),
              ),
              ElevatedButton(
                onPressed: _updateData, // PUT isteği için
                child: const Text('Send PUT Request'),
              ),
              ElevatedButton(
                onPressed: _deleteData, // DELETE isteği için
                child: const Text('Send DELETE Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
