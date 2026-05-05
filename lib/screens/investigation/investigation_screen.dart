import 'package:flutter/material.dart';

import '../../data/environments.dart';
import '../../widgets/environment_card.dart';

class InvestigationScreen extends StatelessWidget {

  const InvestigationScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Investigações"),
      ),

      body: ListView.builder(

        itemCount: environments.length,

        itemBuilder: (context, index) {

          final environment = environments[index];

          return EnvironmentCard(

            environment: environment,

            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(

                SnackBar(
                  content: Text(
                    "Entrando em ${environment.name}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}