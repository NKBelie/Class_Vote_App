import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const ClassVoteApp());

class ClassVoteApp extends StatelessWidget {
  const ClassVoteApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ClassVote',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const ClassVoteHome(),
  );
}
