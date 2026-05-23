import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  runApp(
    MeetingApp(
      hasToken: token != null,
    ),
  );
}

class MeetingApp extends StatefulWidget {
  const MeetingApp({
    super.key,
    required this.hasToken,
  });

  final bool hasToken;

  @override
  State<MeetingApp> createState() => _MeetingAppState();
}

class _MeetingAppState extends State<MeetingApp> {
  @override

void initState() {

  super.initState();

  WidgetsBinding.instance

      .addPostFrameCallback((_) {

    if (widget.hasToken) {

      SyncService.syncAll();

    }

  });

}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meeting App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: widget.hasToken ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
