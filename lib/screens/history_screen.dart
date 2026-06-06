import 'package:flutter/material.dart';
import 'package:med_assistant/models/medicine.dart';
import '../services/history_service.dart';
import '../services/language_service.dart';
import 'medicine_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  final LanguageService? lang;
  final _historyService = HistoryService();

  HistoryScreen({super.key, this.lang});

  @override
  Widget build(BuildContext context) {
    final isTamil = lang?.isTamil ?? false;

    return ListenableBuilder(
      listenable: lang ?? ChangeNotifier(),
      builder: (context, _) {
        final history = _historyService.history;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              lang?.t('Scan History', 'ஸ்கேன் வரலாறு') ?? 'Scan History',
            ),
            actions: [
              if (history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _showClearDialog(context, isTamil),
                ),
            ],
          ),
          body: history.isEmpty
              ? _buildEmptyState(isTamil)
              : _buildHistoryList(context, history),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isTamil) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            lang?.t('No scan history yet', 'இன்னும் ஸ்கேன் வரலாறு இல்லை') ??
                'No scan history yet',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
      BuildContext context, List<Medicine> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final record = history[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Icons.medication, color: Colors.blue),
            title: Text(
              record.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(record.usage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MedicineDetailScreen(medicine: record, lang: lang),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, bool isTamil) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang?.t('Clear History', 'வரலாறு அழி') ?? 'Clear History'),
        content: Text(
          lang?.t(
                'Are you sure you want to clear all history?',
                'எல்லா வரலாறையும் அழிக்க விரும்புகிறீர்களா?',
              ) ??
              'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang?.t('Cancel', 'ரத்து') ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _historyService.clearHistory();
              Navigator.pop(context);
            },
            child: Text(lang?.t('Clear', 'அழி') ?? 'Clear'),
          ),
        ],
      ),
    );
  }
}