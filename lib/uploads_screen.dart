import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class UploadsScreen extends StatefulWidget {
  @override
  _UploadsScreenState createState() => _UploadsScreenState();
}

class _UploadsScreenState extends State<UploadsScreen> {
  List<dynamic> uploadedFiles = [];
  bool isLoading = true;
  String errorMessage = ''; // To store error messages for display

  @override
  void initState() {
    super.initState();
    fetchUploads();
  }

  Future<void> fetchUploads() async {
    setState(() {
      isLoading = true;
      errorMessage = ''; // Clear previous errors
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'User not logged in.';
        });
        return;
      }
      final uid = user.uid;
      final uri = Uri.parse('https://fetch-the-files.vercel.app/uploads?uid=$uid');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          uploadedFiles = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load uploads. Status code: ${response.statusCode}';
        });
        print('Failed to load uploads: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred while fetching uploads: $e';
      });
      print('Error fetching uploads: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Uploads',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            errorMessage,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : uploadedFiles.isEmpty
          ? Center(
        child: Text(
          'No uploads found!',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[400]),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: uploadedFiles.length,
        itemBuilder: (context, index) {
          final file = uploadedFiles[index];
          return Card(
            color: Colors.blueGrey[900],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(
                file['filename'],
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
              ),
              subtitle: Text(
                "Uploaded: ${file['uploadDate']}",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
              ),
              leading: Icon(Icons.file_present, color: Colors.blueAccent),
            ),
          );
        },
      ),
    );
  }
}