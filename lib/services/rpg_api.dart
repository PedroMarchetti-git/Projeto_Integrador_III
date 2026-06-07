import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class RpgApi {
  // URL base do seu Firebase Realtime Database
  static const String _baseUrl = "https://pi3-rpg-default-rtdb.firebaseio.com";

  // Função para buscar os dados de um ambiente específico
  static Future<Map<String, dynamic>?> obterAmbiente(String ambienteId) async {
    try {
      // O Firebase REST exige o '.json' no final da URL
      final url = Uri.parse('$_baseUrl/ambientes/$ambienteId.json');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Se a resposta for bem-sucedida, decodifica o JSON
        if (response.body == 'null') return null;
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint("Erro na requisição: Status ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Erro ao conectar com o Firebase: $e");
      return null;
    }
  }
}
