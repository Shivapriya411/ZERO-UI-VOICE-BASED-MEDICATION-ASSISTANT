import 'package:flutter/material.dart';

import 'services/medicine_database.dart';
import 'services/tts_service.dart';
import 'services/language_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load medicines from JSON
  await MedicineDatabase().load();

  // Initialize Text-to-Speech
  await TtsService().init();

  runApp(const MedAssistantApp());
}

class MedAssistantApp extends StatelessWidget {
  const MedAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService();

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Med Assistant',
          theme: AppTheme.lightTheme,
          home: HomeScreen(lang: lang),
        );
      },
    );
  }
}