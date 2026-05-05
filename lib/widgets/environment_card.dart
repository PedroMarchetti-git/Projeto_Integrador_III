import 'package:flutter/material.dart';
import '../models/environment.dart';

class EnvironmentCard extends StatelessWidget {

  final Environment environment;
  final VoidCallback onTap;

  const EnvironmentCard({
    super.key,
    required this.environment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      child: ListTile(

        title: Text(environment.name),

        subtitle: Text(environment.description),

        trailing: const Icon(Icons.arrow_forward),

        onTap: onTap,
      ),
    );
  }
}