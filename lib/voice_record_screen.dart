import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:just_audio/just_audio.dart';

class VoiceRecordScreen extends StatefulWidget {
  @override
  _VoiceRecordScreenState createState() => _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen> {
  File? _selectedFile;
  Map<String, dynamic>? _analysisResult;
  bool _isLoading = false;
  bool _isPlaying = false;
  final _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _pickAudio(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      File audioFile = File(file.path!);

      setState(() {
        _selectedFile = audioFile;
        _isLoading = true;
        _analysisResult = null;
      });

      _analyzeAudio(context);
    }
  }

  Future<void> _analyzeAudio(BuildContext context) async {
    if (_selectedFile == null) return;

    try {
      List<int> audioBytes = await _selectedFile!.readAsBytes();
      String base64Audio = base64Encode(audioBytes);
      String requestId = Uuid().v4();

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Map<String, dynamic> requestBody = {
        "doc_base64": base64Audio,
        "req_id": requestId,
      };

      var response = await http.post(
        Uri.parse('https://voicedetect.vercel.app/deepfake-check'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        setState(() {
          _analysisResult = jsonDecode(response.body);
          _isLoading = false;
        });

        await _audioPlayer.setFilePath(_selectedFile!.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to analyze audio.')));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error analyzing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred during processing.')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePlayback() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          duration: Duration(milliseconds: 700),
          child: Text(
            'Echoseal Voice Detector',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedFile != null)
                  FadeIn(
                    child: Column(
                      children: [
                        Card(
                          color: Colors.blueGrey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Text(
                                  _selectedFile!.path.split('/').last.length > 25
                                      ? _selectedFile!.path.split('/').last.substring(0, 25) + "..."
                                      : _selectedFile!.path.split('/').last,
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Icon(Icons.audiotrack, size: 50, color: Colors.white),
                                SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _togglePlayback,
                                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                                  label: Text(_isPlaying ? "Pause" : "Play", style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_analysisResult != null)
                          FadeInUp(
                            child: Card(
                              color: Color.fromRGBO(0,0,0,0.6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Analysis Result',
                                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Divider(color: Colors.white24),
                                    Text(
                                      'Real Confidence: ${(_analysisResult!['confidence']['real'] * 100).toStringAsFixed(2)}%',
                                      style: TextStyle(color: Colors.greenAccent, fontSize: 16),
                                    ),
                                    Text(
                                      'Fake Confidence: ${(_analysisResult!['confidence']['fake'] * 100).toStringAsFixed(2)}%',
                                      style: TextStyle(color: Colors.redAccent, fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (_isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: BounceInUp(
        duration: Duration(milliseconds: 800),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.blueAccent,
          onPressed: () => _pickAudio(context),
          icon: Icon(Icons.upload_file, color: Colors.white),
          label: Text("Upload", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
