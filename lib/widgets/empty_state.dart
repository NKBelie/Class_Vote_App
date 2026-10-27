import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.description, this.action});
  final IconData icon;
  final String title;
  final String description;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Center(child: Column(children: [
        CircleAvatar(radius: 30, backgroundColor: lightPurple, child: Icon(icon, color: primaryPurple, size: 30)),
        const SizedBox(height: 14),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkPurple)),
        const SizedBox(height: 8),
        Text(description, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        if (action != null) ...[const SizedBox(height: 16), action!],
      ])),
    ),
  );
}
