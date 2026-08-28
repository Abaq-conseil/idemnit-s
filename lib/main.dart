import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/selection_personne_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jyrzxvkuggmsvryanmiy.supabase.co',
    publishableKey: 'sb_publishable__NCCE2x8MxwtQ36H9C6vig_hWLxAX1w',
  );

  runApp(const IndemnitesApp());
}

class IndemnitesApp extends StatelessWidget {
  const IndemnitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Indemnités',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SelectionPersonneScreen(),
    );
  }
}