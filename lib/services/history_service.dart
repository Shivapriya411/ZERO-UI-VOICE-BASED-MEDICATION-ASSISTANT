import '../models/medicine.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  final List<Medicine> _history = [];

  void addRecord(Medicine med) {
    _history.insert(0, med);
  }

  // ✅ main getter
  List<Medicine> get history => _history;

  // ✅ FIX for home_screen (you were using records)
  List<Medicine> get records => _history;

  // ✅ FIX for clear button
  void clearHistory() {
    _history.clear();
  }
}