import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import '../services/medicine_database.dart';
import '../services/language_service.dart';
import '../services/history_service.dart';
import '../services/tts_service.dart';
import '../models/medicine.dart';
import 'medicine_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  final LanguageService? lang;

  const ScanScreen({super.key, this.lang});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  final MedicineDatabase _medicineDb = MedicineDatabase();
  final HistoryService _historyService = HistoryService();
  final TtsService _ttsService = TtsService();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _medicineDb.load(); // IMPORTANT
  }

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lang?.t('Scan Medicine', 'மருந்தை ஸ்கேன் செய்யவும்') ??
              'Scan Medicine',
        ),
      ),
      body: Center(
        child: _isProcessing
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _scanMedicine,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  widget.lang?.t('Scan Medicine', 'ஸ்கேன் செய்யவும்') ??
                      'Scan Medicine',
                ),
              ),
      ),
    );
  }

  Future<void> _scanMedicine() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final recognizedText =
          await _textRecognizer.processImage(inputImage);

      final extractedText = recognizedText.text;

      print("OCR TEXT: $extractedText");

      final medicine = _findMedicine(extractedText);

      setState(() => _isProcessing = false);

      if (medicine != null) {
        print("DEBUG: Medicine found - ${medicine.name}");
        _historyService.addRecord(medicine);
        print("DEBUG: Record added to history");

        try {
          await _ttsService.speak(
            widget.lang?.isTamil == true
                ? '${medicine.name} ${medicine.usage}'
                : 'This is ${medicine.name}. ${medicine.usage}',
            isTamil: widget.lang?.isTamil ?? false,
          );
          print("DEBUG: TTS spoke successfully");
        } catch (ttsError) {
          print("TTS Error: $ttsError");
        }

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicineDetailScreen(
              medicine: medicine,
              lang: widget.lang,
            ),
          ),
        );
      } else {
        _showNotFound();
      }
    } catch (e) {
      print("Scan Error: $e");
      setState(() => _isProcessing = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Medicine? _findMedicine(String text) {
    final lower = text.toLowerCase().trim();
    print("DEBUG: Starting medicine search with text: $lower");
    print("DEBUG: Total medicines in database: ${_medicineDb.all.length}");

    // First pass: Direct name/generic match (exact contains)
    for (var med in _medicineDb.all) {
      final name = med.name.toLowerCase();
      final generic = med.generic.toLowerCase();

      if (lower.contains(name) || lower.contains(generic)) {
        print("MATCH FOUND: ${med.name} (direct match)");
        return med;
      }
    }

    // Second pass: Bidirectional word matching
    for (var med in _medicineDb.all) {
      final name = med.name.toLowerCase();
      final generic = med.generic.toLowerCase();

      for (var word in lower.split(' ')) {
        if (word.length > 2) { // Minimum 3 characters
          // Check if medicine name contains word OR word contains medicine name
          if (name.contains(word) || generic.contains(word) || word.contains(name) || word.contains(generic)) {
            print("MATCH FOUND: ${med.name} (bidirectional word match: '$word')");
            return med;
          }
        }
      }
    }

    // Third pass: Split medicine name and check for partial matches
    for (var med in _medicineDb.all) {
      final name = med.name.toLowerCase();
      final generic = med.generic.toLowerCase();

      for (var medWord in name.split(RegExp(r'[\s\-]+'))) {
        if (medWord.length > 2 && lower.contains(medWord)) {
          print("MATCH FOUND: ${med.name} (flexible match: '$medWord')");
          return med;
        }
      }

      for (var genWord in generic.split(RegExp(r'[\s\-]+'))) {
        if (genWord.length > 2 && lower.contains(genWord)) {
          print("MATCH FOUND: ${med.name} (generic match: '$genWord')");
          return med;
        }
      }
    }

    print("NO MATCH: No medicine found for text: $lower");
    return null;
  }

  void _showNotFound() async {
    print("NO MATCH: Medicine not detected, showing not found dialog");
    
    final message = widget.lang?.t(
          'Medicine not detected. Please consult a doctor',
          'மருந்து கண்டறியப்படவில்லை. டாக்டரை அணுகவும்.',
        ) ??
        'Medicine not detected. Please consult a doctor';

    try {
      print("DEBUG: Speaking not found message: $message");
      await _ttsService.speak(
        message,
        isTamil: widget.lang?.isTamil ?? false,
      );
      print("DEBUG: TTS not found message completed");
    } catch (e) {
      print("TTS Error in _showNotFound: $e");
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Not Found"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}