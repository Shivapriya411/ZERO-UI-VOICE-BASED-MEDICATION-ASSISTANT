import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/language_service.dart';
import '../services/history_service.dart';
import 'scan_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final LanguageService lang;

  const HomeScreen({super.key, required this.lang});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _historyService = HistoryService();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.lang,
      builder: (context, _) {
        final isTamil = widget.lang.isTamil;
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lang.t('Medication Assistant', 'மருந்து உதவி'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.lang.t('Zero-UI Voice Based System', 'பூஜ்ய UI குரல் அடிப்படை'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isTamil ? Icons.language : Icons.translate,
                  color: isTamil ? Colors.orange : null,
                ),
                onPressed: () => widget.lang.toggle(),
                tooltip: isTamil ? 'English' : 'தமிழ்',
              ),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeContent(isTamil),
              HistoryScreen(lang: widget.lang),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: widget.lang.t('Home', 'முகப்பு'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_outlined),
                selectedIcon: const Icon(Icons.history),
                label: widget.lang.t('History', 'வரலாறு'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(bool isTamil) {
    final historyRecords = _historyService.records;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Welcome Card
          _buildWelcomeCard(isTamil),
          const SizedBox(height: 20),
          // Big Scan Button
          _buildScanButton(),
          const SizedBox(height: 20),
          // Grid of 4 cards
          _buildGridCards(isTamil, historyRecords),
          const SizedBox(height: 20),
          // Emergency Call Button
          _buildEmergencyButton(isTamil),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(bool isTamil) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lang.t('I will help you with your medicines', 'நான் உங்கள் மருந்துகளுக்கு உதவி'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lang.t('Scan, listen and stay safe', 'ஸ்கேன் செய்யவும், கேளுங்கள் மற்றும் பாதுகாப்பாக இருங்கள்'),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.volume_up, size: 40, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanScreen(lang: widget.lang),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.green.shade600,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Icon(Icons.camera_alt, size: 60, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                widget.lang.t('SCAN MEDICINE', 'மருந்தை ஸ்கேன் செய்யவும்'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.lang.t('Tap to scan medicine', 'மருந்தை ஸ்கேன் செய்ய ট்যাப் செய்யவும்'),
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCards(bool isTamil, List historyRecords) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Language Card
        _buildGridCard(
          icon: Icons.language,
          title: widget.lang.t('Language', 'மொழி'),
          subtitle: isTamil ? 'Tamil' : 'English',
          color: Colors.orange,
          onTap: () => widget.lang.toggle(),
        ),
        // History Card
        _buildGridCard(
          icon: Icons.history,
          title: widget.lang.t('Recent', 'சமீபத்திய'),
          subtitle: historyRecords.isEmpty 
            ? widget.lang.t('No scans', 'ஸ்கேன் இல்லை')
            : '${historyRecords.length} ${widget.lang.t('scanned', 'ஸ்கேன் செய்யப்பட்ட')}',
          color: Colors.purple,
          onTap: () {
            setState(() => _selectedIndex = 1);
          },
        ),
        // Voice Input Card
        _buildGridCard(
          icon: Icons.mic,
          title: widget.lang.t('Voice', 'குரல்'),
          subtitle: widget.lang.t('Say "Scan"', '"ஸ்கேன்" சொல்லுங்கள்'),
          color: Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanScreen(lang: widget.lang),
              ),
            );
          },
        ),
        // Share to Doctor Card
        _buildGridCard(
          icon: Icons.share,
          title: widget.lang.t('Share', 'பகிர்'),
          subtitle: widget.lang.t('To Doctor', 'டாக்டர்க்கு'),
          color: Colors.teal,
          onTap: () => _shareToDoctor(historyRecords),
        ),
      ],
    );
  }

  Widget _buildGridCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(bool isTamil) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showEmergencyDialog(isTamil),
        icon: const Icon(Icons.emergency, size: 24),
        label: Text(
          widget.lang.t('EMERGENCY CALL', 'அவசர அழைப்பு'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showEmergencyDialog(bool isTamil) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.lang.t('Emergency Contacts', 'அவசர தொடர்பு')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red.shade600),
              title: Text(widget.lang.t('Ambulance', 'অ্যাম্বুলেন্স')),
              subtitle: const Text('102'),
              onTap: () {
                _makeCall('tel:102');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.orange.shade600),
              title: Text(widget.lang.t('Police', 'পুলিস')),
              subtitle: const Text('100'),
              onTap: () {
                _makeCall('tel:100');
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(widget.lang.t('Close', 'বন্ধ')),
          ),
        ],
      ),
    );
  }

  void _makeCall(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareToDoctor(List historyRecords) async {
    if (historyRecords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.lang.t('No history to share', 'பகிர்ந்து கொள்ள வரலாறு இல்லை'))),
      );
      return;
    }

    String shareText = 'My Medicine History:\n\n';
    for (var record in historyRecords.take(5)) {
      shareText += '• ${record.medicine.name} (${record.formattedTime})\n';
    }

    final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(shareText)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.lang.t('Could not share', 'பகிர முடியவில்லை'))),
      );
    }
  }
}