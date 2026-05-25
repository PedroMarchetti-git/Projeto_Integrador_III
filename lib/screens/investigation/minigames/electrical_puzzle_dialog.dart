import 'package:flutter/material.dart';

class ElectricalPuzzleDialog extends StatefulWidget {
  const ElectricalPuzzleDialog({super.key});

  @override
  State<ElectricalPuzzleDialog> createState() =>
      _ElectricalPuzzleDialogState();
}

class _ElectricalPuzzleDialogState
    extends State<ElectricalPuzzleDialog> {

  final TextEditingController answerController =
      TextEditingController();

  String errorMessage = "";

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: const Text("Reconstruir Sistema"),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text(
            "Complete a sequência lógica para restaurar o painel:\n\n"
            "2 - 4 - 8 - ?",
            style: TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: answerController,
            keyboardType: TextInputType.number,

            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Digite a resposta",
            ),
          ),

          const SizedBox(height: 10),

          if (errorMessage.isNotEmpty)
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancelar"),
        ),

        ElevatedButton(
          onPressed: () {

            if (answerController.text.trim() == "16") {

              Navigator.pop(context, true);

            } else {

              setState(() {
                errorMessage = "Código incorreto.";
              });
            }
          },

          child: const Text("Confirmar"),
        ),
      ],
    );
  }
}