import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = "English";
  String _selectedTheme = "Default";

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          duration: Duration(milliseconds: 700),
          child: Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.06,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.07),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            children: [
              _buildSettingsTile(
                title: "Notifications",
                icon: Icons.notifications,
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              _buildSettingsTile(
                title: "Privacy & Security",
                icon: Icons.lock,
                onTap: () {
                  _showPrivacyDialog();
                },
              ),
              _buildSettingsTile(
                title: "Help & Support",
                icon: Icons.help_outline,
                onTap: () {
                  _showHelpDialog();
                },
              ),
              _buildSettingsTile(
                title: "About App",
                icon: Icons.info,
                onTap: () {
                  _showAboutDialog();
                },
              ),
              SizedBox(height: screenHeight * 0.03),
              FadeInUp(
                duration: Duration(milliseconds: 800),
                child: Text(
                  "Manage your preferences and personalize your experience",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.04,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required String title, required IconData icon, Widget? trailing, VoidCallback? onTap}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return FadeInUp(
      duration: Duration(milliseconds: 800),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Color(0xFF1E2A38),
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.white, size: screenWidth * 0.07),
          title: Text(
            title,
            style: GoogleFonts.poppins(fontSize: screenWidth * 0.05, color: Colors.white),
          ),
          trailing: trailing ?? Icon(Icons.arrow_forward_ios, color: Colors.white, size: screenWidth * 0.05),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    // Show privacy settings dialog
  }

  void _showStorageInfo() {
    // Show storage info dialog
  }

  void _showHelpDialog() {
    // Show help and support info
  }

  void _showAboutDialog() {
    // Show about app info
  }
}
