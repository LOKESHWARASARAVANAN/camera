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
  String? _errorMessage; // Variable to hold error message

  void _startStream() {
    try {
      // Hardcoded RTSP URL
      final username = 'admin';
      final password = 'Admin@123';
      final ipAddress = '172.16.0.123';
      final rtspUrl = 'rtsp://$username:${Uri.encodeComponent(password)}@$ipAddress:554/ch01/0';

      // Dispose previous controller if it exists
      _videoPlayerController?.dispose();

      // Create a new controller for the RTSP stream
      _videoPlayerController = VlcPlayerController.network(
        rtspUrl,
        hwAcc: HwAcc.auto,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );

      // Error Handling
      _videoPlayerController!.addListener(() {
        if (!_videoPlayerController!.value.isInitialized) {
          setState(() {
            _errorMessage = 'Controller not initialized';
          });
        }

        if (_videoPlayerController!.value.hasError) {
          setState(() {
            _errorMessage = 'Error: ${_videoPlayerController!.value.errorDescription}';
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
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live RTSP Stream'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _startStream,
            child: const Text('Start Stream'),
          ),
          if (_errorMessage != null) // Display error message if exists
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: _isPlaying && _videoPlayerController != null
                ? VlcPlayer(
              controller: _videoPlayerController!,
              aspectRatio: 16 / 9,
              placeholder: const Center(
                child: CircularProgressIndicator(),
              ),
            )
                : const Center(
              child: Text('Click the button to start streaming'),
            ),
          ),
        ],
      ),
    );
  }
}
