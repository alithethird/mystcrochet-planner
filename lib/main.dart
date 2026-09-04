import 'package:flutter/material.dart';
import 'providers/project_provider.dart';
import 'screens/home_screen.dart';
import 'services/localization.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MystCrochetApp());
}

class MystCrochetApp extends StatefulWidget {
  const MystCrochetApp({super.key});

  @override
  State<MystCrochetApp> createState() => _MystCrochetAppState();
}

class _MystCrochetAppState extends State<MystCrochetApp> {
  final ProjectProvider _projectProvider = ProjectProvider();
  final LocalizationService _localizationService = LocalizationService();

  @override
  void initState() {
    super.initState();
    _localizationService.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _localizationService.removeListener(_onLocaleChanged);
    _projectProvider.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MystCrochet Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(projectProvider: _projectProvider),
    );
  }
}
