import 'package:flutter/material.dart';
import 'package:quick_request/quick_request.dart';

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
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _responseMessage = 'No data fetched yet';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final apiRequest = QuickRequest();

    try {
      final response = await apiRequest.request(
        url: 'https://jsonplaceholder.typicode.com/posts/1',
        requestMethod: RequestMethod.GET,
      );

      if (!response.error) {
        setState(() {
          _responseMessage = 'Data: ${response.data}';
        });
      } else {
        setState(() {
          _responseMessage = 'Error: ${response.message}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Exception: $e';
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
          child: Text(
            _responseMessage,
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
