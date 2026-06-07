import 'package:flutter/material.dart';
 
class ClueCard extends StatelessWidget {
  final String clue;

  const ClueCard({
    super.key,
    required this.clue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black.withValues(),

      margin: const EdgeInsets.symmetric(vertical: 6),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(

        leading: const Icon(
          Icons.auto_awesome,
          color: Colors.amber,
        ),

        title: Text(
          clue,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}