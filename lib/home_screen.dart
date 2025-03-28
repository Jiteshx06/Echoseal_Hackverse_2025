import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart';
import 'support_screen.dart';
import 'profile_screen.dart';
import 'video_record_screen.dart';
import 'voice_record_screen.dart';
import 'uploads_screen.dart';
import 'chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String? _profileImageBase64;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc =
        await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _profileImageBase64 = doc['profileImageBase64'];
          });
        }
      }
    } catch (e) {
      print("Max 1 mb can be uploaded");
    }
  }

  final List<Widget> _pages = [
    HomeContent(),
    SupportScreen(),
    SettingsScreen(),
    ProfileScreen(),
    ChatbotScreen(),
  ];

  void _onNavItemTapped(int index) {
    if (index >= 0 && index < 3) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => index == 3 ? ProfileScreen() : ChatbotScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          duration: Duration(milliseconds: 700),
          child: Text(
            'Echoseal',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          FadeInRight(
            duration: Duration(milliseconds: 800),
            child: IconButton(
              icon: CircleAvatar(
                radius: screenWidth * 0.06,
                backgroundImage: _profileImageBase64 != null
                    ? MemoryImage(base64Decode(_profileImageBase64!)) as ImageProvider
                    : const AssetImage('assets/images/profile.png'),
              ),
              onPressed: () => _onNavItemTapped(3),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      floatingActionButton: FadeInRight(
        duration: Duration(milliseconds: 800),
        child: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () => _onNavItemTapped(4),
          child: Icon(Icons.smart_toy, size: screenWidth * 0.07, color: Colors.white),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF151A25),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey[500],
          showSelectedLabels: true,
          showUnselectedLabels: false,
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home, size: screenWidth * 0.07), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.support_agent, size: screenWidth * 0.07), label: 'Support'),
            BottomNavigationBarItem(icon: Icon(Icons.settings, size: screenWidth * 0.07), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {
      'title': 'Video Recording',
      'icon': Icons.videocam_rounded,
      'screen': VideoRecordScreen(),
      'description': 'Capture and upload videos'
    },
    {
      'title': 'Voice Recording',
      'icon': Icons.mic_rounded,
      'screen': VoiceRecordScreen(),
      'description': 'Upload high-quality voice notes'
    },
    {
      'title': 'My Uploads',
      'icon': Icons.cloud_upload_rounded,
      'screen': UploadsScreen(),
      'description': 'View all your stored media'
    }
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: screenHeight * 0.03),
        BounceInDown(
          duration: Duration(milliseconds: 1200),
          child: Center(
            child: Text(
              "Features",
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.045,
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Expanded(
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return FadeInUp(
                duration: Duration(milliseconds: 800 + (index * 100)),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => feature['screen'])),
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(feature['icon'], size: screenWidth * 0.07, color: Colors.blueAccent),
                        SizedBox(width: screenWidth * 0.04),
                        Text(
                          feature['title'],
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios, size: screenWidth * 0.04, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}