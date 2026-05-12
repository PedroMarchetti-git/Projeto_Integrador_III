import 'package:flutter/material.dart';

class ClueCard extends StatelessWidget {
  final String clue;

  const ClueCard({super.key, required this.clue});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.indigo.shade50,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: const Icon(Icons.auto_awesome, color: Colors.indigo),
        title: Text(
          clue,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
