import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'rescue_team_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://iqwbgmlpkfaqytjqcphh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imlxd2JnbWxwa2ZhcXl0anFjcGhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU1OTMwNzEsImV4cCI6MjA4MTE2OTA3MX0.HzwheFwYCrjUJ6KRQfAoMkrJU60GoMD2Y9uJZMX__nY',
  );

  runApp(const RescueTeamApp());
}
