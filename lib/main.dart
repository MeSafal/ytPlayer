import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the services package
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool showUI = true; // Whether to show the UI elements

  @override
  void initState() {
    super.initState();
    _initializeController();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive); // Hide the status bar
  }

  @override
  void dispose() {
    _controller.dispose();
    _urlController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // Restore the status bar
    super.dispose();
  }

  _initializeController() {
    _controller = YoutubePlayerController(
      initialVideoId: 'Y8ZGvYobkrk',
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    // Listen for player state changes
    _controller.addListener(listener);
  }

  // Listener for player state changes
  void listener() {
    if (_controller.value.playerState == PlayerState.ended) {
      print("Video has ended.");
    } else if (_controller.value.playerState == PlayerState.unknown) {
      print("Video is in an unknown state, possibly due to an error.");
    }
  }

  // Callback for full-screen mode change
  void onFullScreenChange(bool isFullScreen) {
    setState(() {
      showUI = !isFullScreen;
    });
  }

  void playVideoFromUrl(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId is String) {
      _controller.load(videoId);
      _controller.play();
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Invalid YouTube Video URL"),
            content: Text("The provided URL is not a valid YouTube video URL."),
            actions: <Widget>[
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_controller.value.isFullScreen) {
          _controller.toggleFullScreenMode();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: showUI
            ? AppBar(
                backgroundColor: Colors.grey,
                title: Text("Youtube Player"),
              )
            : null, // Hide the app bar when in full-screen mode
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                if (showUI)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: "Enter YouTube URL",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                if (showUI)
                  ElevatedButton(
                    onPressed: () {
                      final url = _urlController.text;
                      playVideoFromUrl(url);
                    },
                    child: Text("Play Video"),
                  ),
                Expanded(
                  child: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    onReady: () {
                      _controller.addListener(() {
                        onFullScreenChange(_controller.value.isFullScreen);
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
