import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class LiveStreamScreen extends StatefulWidget {
  const LiveStreamScreen({super.key});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  VlcPlayerController? _videoPlayerController;
  bool _isPlaying = false;
  String? _errorMessage;

  // Controllers for input fields with default values
  final TextEditingController _ipController =
  TextEditingController(text: '172.16.0.123');
  final TextEditingController _portController =
  TextEditingController(text: '554');
  final TextEditingController _usernameController =
  TextEditingController(text: 'admin');
  final TextEditingController _passwordController =
  TextEditingController(text: 'Admin@123');

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _ipController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to start the stream using user input
  void _startStream() {
    try {
      // Get the values from the input fields
      final ipAddress = _ipController.text;
      final port = _portController.text;
      final username = _usernameController.text;
      final password = _passwordController.text;

      // Validate if inputs are provided
      if (ipAddress.isEmpty || port.isEmpty || username.isEmpty || password.isEmpty) {
        setState(() {
          _errorMessage = 'All fields are required';
        });
        return;
      }

      final rtspUrl =
          'rtsp://$username:${Uri.encodeComponent(password)}@$ipAddress:$port/ch01/0';

      // Dispose the previous controller if it exists
      _videoPlayerController?.dispose();

      // Create a new controller for the RTSP stream
      _videoPlayerController = VlcPlayerController.network(
        rtspUrl,
        hwAcc: HwAcc.auto,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );

      // Error handling for the controller
      _videoPlayerController!.addListener(() {
        if (!_videoPlayerController!.value.isInitialized) {
          setState(() {
            _errorMessage = 'Controller not initialized';
          });
        }

        if (_videoPlayerController!.value.hasError) {
          setState(() {
            _errorMessage =
            'Error: ${_videoPlayerController!.value.errorDescription}';
          });
        }
      });

      setState(() {
        _isPlaying = true;
        _errorMessage = null; // Reset error message
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error starting stream: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live RTSP Stream'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input fields for IP, Port, Username, Password with default values
            TextFormField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // Hide password
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _startStream,
              child: const Text('Start Stream'),
            ),

            // Display error message if exists
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // Video Player
            Expanded(
              child: _isPlaying && _videoPlayerController != null
                  ? VlcPlayer(
                controller: _videoPlayerController!,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              )
                  : const Center(
                child: Text('Enter camera details and start streaming'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
