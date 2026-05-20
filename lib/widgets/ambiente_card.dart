import 'package:flutter/material.dart';
import '../models/ambiente.dart';

class AmbienteCard extends StatelessWidget {

  final Ambiente ambiente;
  final VoidCallback onTap;

  const AmbienteCard({
    super.key,
    required this.ambiente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: ListTile(
        title: Text(ambiente.nome),
        subtitle: Text(ambiente.descricao),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}