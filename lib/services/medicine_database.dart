import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/medicine.dart';

class MedicineDatabase {
  static final MedicineDatabase _instance = MedicineDatabase._internal();
  factory MedicineDatabase() => _instance;
  MedicineDatabase._internal();

  final List<Medicine> _medicines = [];

  List<Medicine> get medicines => _medicines;
  List<Medicine> get all => _medicines;

  // 🔹 Load medicines from JSON
  Future<void> load() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/medicines.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      _medicines.clear();
      _medicines.addAll(
        jsonList.map((json) => Medicine.fromJson(json)).toList(),
      );
      print("DEBUG: Medicine database loaded successfully. Total medicines: ${_medicines.length}");
    } catch (e) {
      print("Error loading medicines: $e");
    }
  }

  // 🔹 OLD search (keep if needed)
  Medicine? getMedicineByName(String name) {
    try {
      return _medicines.firstWhere(
        (m) =>
            m.name.toLowerCase().contains(name.toLowerCase()) ||
            m.generic.toLowerCase().contains(name.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  // 🔹 SIMPLE search
  Medicine? findByName(String name) {
    final lower = name.toLowerCase().trim();
    try {
      return _medicines.firstWhere(
        (m) =>
            m.name.toLowerCase().contains(lower) ||
            m.generic.toLowerCase().contains(lower),
      );
    } catch (_) {
      return null;
    }
  }

  // 🔥 FINAL SMART SEARCH (USE THIS)
  Medicine? smartSearch(String text) {
    final lower = text.toLowerCase();

    print("OCR TEXT: $lower"); // Debug print

    for (var med in _medicines) {
      final name = med.name.toLowerCase();
      final generic = med.generic.toLowerCase();

      // Direct match
      if (lower.contains(name) || lower.contains(generic)) {
        return med;
      }

      // Partial word match
      for (var word in lower.split(' ')) {
        if (name.contains(word) || generic.contains(word)) {
          return med;
        }
      }
    }

    return null;
  }
}