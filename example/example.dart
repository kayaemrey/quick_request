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
  // Variable to display the API response
  String _responseMessage = 'No data fetched yet';

  /// Sends a POST request to the API (create data).
  Future<void> _createData() async {
    final apiRequest = QuickRequest();
    try {
      final response = await apiRequest.request<Map<String, dynamic>>(
        url: 'https://jsonplaceholder.typicode.com/posts',
        requestMethod: RequestMethod.POST,
        body: {
          'title': 'New Post',
          'body': 'This post was created using the POST method',
          'userId': 1,
        },
        fromJson: (json) => json, // Directly return the JSON response
      );

      setState(() {
        _responseMessage = response.error == false
            ? 'POST Success: ${response.data}'
            : 'POST Error: ${response.message}';
      });
    } catch (e) {
      setState(() {
        _responseMessage = 'POST Exception: $e';
      });
    }
  }

  /// Sends a PUT request to the API (update existing data).
  Future<void> _updateData() async {
    final apiRequest = QuickRequest();
    try {
      final response = await apiRequest.request<Map<String, dynamic>>(
        url: 'https://jsonplaceholder.typicode.com/posts/1',
        requestMethod: RequestMethod.PUT,
        body: {
          'id': 1,
          'title': 'Updated Post',
          'body': 'This post was updated using the PUT method',
          'userId': 1,
        },
        fromJson: (json) => json, // Directly return the JSON response
      );

      setState(() {
        _responseMessage = response.error == false
            ? 'PUT Success: ${response.data}'
            : 'PUT Error: ${response.message}';
      });
    } catch (e) {
      setState(() {
        _responseMessage = 'PUT Exception: $e';
      });
    }
  }

  /// Sends a DELETE request to the API (delete data).
  Future<void> _deleteData() async {
    final apiRequest = QuickRequest();
    try {
      final response = await apiRequest.request<void>(
        url: 'https://jsonplaceholder.typicode.com/posts/1',
        requestMethod: RequestMethod.DELETE,
        fromJson: (_) => null, // No need to parse the response for DELETE
      );

      setState(() {
        _responseMessage = response.error == false
            ? 'DELETE Success'
            : 'DELETE Error: ${response.message}';
      });
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
        title: const Text('Quick Request Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _responseMessage, // Display the API response here
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createData, // For POST request
                child: const Text('Send POST Request'),
              ),
              ElevatedButton(
                onPressed: _updateData, // For PUT request
                child: const Text('Send PUT Request'),
              ),
              ElevatedButton(
                onPressed: _deleteData, // For DELETE request
                child: const Text('Send DELETE Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
