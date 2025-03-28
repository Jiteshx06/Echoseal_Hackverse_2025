import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatelessWidget {
  final String supportEmail = "jiteshp277@gmail.com";
  final String supportPhone = "7045714602";
  final String whatsappNumber = "917045714602";
  final String feedbackFormURL = "https://docs.google.com/forms/d/e/1FAIpQLSf0H9MSWRgn4Iek-gW8pe4r4pMPC7m-7KsvLmuXxGskK3w7TA/viewform?usp=dialog";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeInDown(
          duration: Duration(milliseconds: 700),
          child: Text(
            'Support',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            FadeInUp(
              duration: Duration(milliseconds: 800),
              child: Text(
                'How can we help you?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 30),

            FadeInLeft(
              duration: Duration(milliseconds: 900),
              child: _supportOption(
                icon: Icons.email_rounded,
                title: 'Email Support',
                subtitle: supportEmail,
                onTap: () => _sendEmail(),
              ),
            ),

            FadeInRight(
              duration: Duration(milliseconds: 1000),
              child: _supportOption(
                icon: Icons.phone_rounded,
                title: 'Call Support',
                subtitle: supportPhone,
                onTap: () => _makePhoneCall(),
              ),
            ),

            FadeInLeft(
              duration: Duration(milliseconds: 1100),
              child: _supportOption(
                icon: Icons.chat_bubble_rounded,
                title: 'Live Chat (WhatsApp)',
                subtitle: 'Chat with us on WhatsApp',
                onTap: () => _openWhatsApp(),
              ),
            ),

            Spacer(),

            FadeInUp(
              duration: Duration(milliseconds: 1200),
              child: TextButton(
                onPressed: feedbackFormURL.isNotEmpty ? () => _openFeedbackForm() : null,
                child: Text(
                  'Give us Feedback',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: feedbackFormURL.isNotEmpty ? Colors.blueAccent : Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Support Option Widget
  Widget _supportOption({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 30),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400])),
        trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey[400], size: 20),
        onTap: onTap,
      ),
    );
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'jiteshp277@gmail.com',
      queryParameters: {
        'subject': 'Support Request',
        'body': 'Hello, I need help with...',
      },
    );

    try {
      bool launched = await launchUrl(emailUri);

      if (!launched) {
        // Fallback: Open Gmail directly
        final Uri gmailUri = Uri.parse("https://mail.google.com/mail/?view=cm&fs=1&to=jiteshp277@gmail.com&su=Support%20Request&body=Hello%2C%20I%20need%20help%20with...");
        await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print("Error launching email app: $e");
    }
  }

  void _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: supportPhone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      print("Could not launch phone app");
    }
  }

  void _openWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/$whatsappNumber?text=${Uri.encodeComponent("Hello, I need support.")}");

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not open WhatsApp");
    }
  }

  void _openFeedbackForm() async {
    final Uri feedbackUri = Uri.parse(feedbackFormURL);
    if (await canLaunchUrl(feedbackUri)) {
      await launchUrl(feedbackUri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not open feedback form");
    }
  }
}
