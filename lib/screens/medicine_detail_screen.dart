import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/tts_service.dart';
import '../services/language_service.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;
  final LanguageService? lang;

  const MedicineDetailScreen({super.key, required this.medicine, this.lang});

  @override
  Widget build(BuildContext context) {
    final isTamil = lang?.isTamil ?? false;
    return ListenableBuilder(
      listenable: lang ?? ChangeNotifier(),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(medicine.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () => _speakInfo(isTamil),
                tooltip: lang?.t('Speak', 'பேசு') ?? 'Speak',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareInfo(),
                tooltip: lang?.t('Share', 'பகிர்') ?? 'Share',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isTamil),
                const SizedBox(height: 16),
                _buildInfoCard(
                  lang?.t('Generic Name', 'பொதுப் பெயர்') ?? 'Generic Name',
                  medicine.generic,
                  Icons.science,
                  Colors.purple,
                ),
                _buildInfoCard(
                  lang?.t('Category', 'வகை') ?? 'Category',
                  medicine.category,
                  Icons.category,
                  Colors.blue,
                ),
                _buildInfoCard(
                  lang?.t('Usage', 'பயன்படுத்தல்') ?? 'Usage',
                  medicine.usage,
                  Icons.info_outline,
                  Colors.green,
                ),
                _buildInfoCard(
                  lang?.t('Dosage', 'டோஸ்') ?? 'Dosage',
                  medicine.dosage,
                  Icons.medication_liquid,
                  Colors.orange,
                ),
                _buildInfoCard(
                  lang?.t('Warning', 'எச்சரிக்கை') ?? 'Warning',
                  medicine.warning,
                  Icons.warning_amber_rounded,
                  Colors.red,
                  isWarning: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isTamil) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication,
                size: 40,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    medicine.generic,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon, Color color, {bool isWarning = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isWarning ? Colors.red.shade50 : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isWarning ? Colors.red.shade100 : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isWarning ? Colors.red : color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isWarning ? Colors.red : color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content.isEmpty ? (lang?.t('No information available', 'தகவல் இல்லை') ?? 'No information available') : content,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _speakInfo(bool isTamil) {
    final tts = TtsService();
    final text = '${medicine.name}. ${medicine.generic}. ${medicine.usage}. ${medicine.dosage}. ${medicine.warning}';
    tts.speak(text, isTamil: isTamil);
  }

  void _shareInfo() {
    final text = medicine.toShareText();
    // Using Flutter's share functionality would require share_plus package
    // For now, we'll use a simple clipboard copy
    // In production, add share_plus to pubspec.yaml
  }
}