import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class VideoRecordScreen extends StatefulWidget {
  @override
  _VideoRecordScreenState createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> {
  File? _videoFile;
  VideoPlayerController? _controller;
  String? _aiResponse;
  bool _isProcessing = false;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      setState(() {});
    }
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      File selectedVideo = File(result.files.first.path!);
      _setVideo(selectedVideo);
      await _processVideo(selectedVideo);
    }
  }

  void _setVideo(File video) {
    setState(() {
      _videoFile = video;
      _controller = VideoPlayerController.file(video)
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    });
  }

  Future<void> _processVideo(File videoFile) async {
    setState(() => _isProcessing = true);
    try {
      List<int> videoBytes = await videoFile.readAsBytes();
      String base64Video = base64Encode(videoBytes);
      await _detectAI(base64Video);
    } catch (e) {
      _showSnackbar('Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _detectAI(String base64Video) async {
    try {
      var response = await http.post(
        Uri.parse('https://videodetect.vercel.app/deepfake-video-check'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "doc_base64": base64Video,
          "req_id": "test-video-123",
          "doc_type": "video",
          "isIOS": false,
          "orientation": 0
        }),
      );
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() => _aiResponse = jsonResponse['result']);
      } else {
        _showSnackbar('Error: Failed to analyze video');
      }
    } catch (e) {
      _showSnackbar('Detection Error: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Color _getResponseColor() {
    if (_aiResponse == null) return Colors.transparent;
    return _aiResponse!.toLowerCase().contains("fake") ? Colors.red : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text('Video Record Detector', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _videoFile == null
                  ? Text('Upload a Video', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[400]))
                  : Card(
                color: Colors.black,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                      if (_isProcessing) Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ),
                      if (_aiResponse != null)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "AI Detection: $_aiResponse",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: _getResponseColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
            children: [FloatingActionButton(
              heroTag: 'upload',
              backgroundColor: Colors.blueAccent,
              onPressed: _pickVideo,
              child: Icon(Icons.upload, color: Colors.white),
              ),
             ]
            )
          ),
        ],
      ),
    );
  }
}