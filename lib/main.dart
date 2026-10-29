import 'package:flutter/material.dart';
import 'models/app_state.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PdfStudioApp());
}

class PdfStudioApp extends StatefulWidget {
  const PdfStudioApp({super.key});

  @override
  State<PdfStudioApp> createState() => _PdfStudioAppState();
}

class _PdfStudioAppState extends State<PdfStudioApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'MarkPDF',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: _appState.themeMode,
          home: HomeScreen(appState: _appState),
        );
      },
    );
  }
}
