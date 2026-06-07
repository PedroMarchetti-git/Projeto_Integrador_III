import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RealtimeService {
  // URL Base do seu Realtime Database
  static const String _baseUrl = "https://firebaseio.com";

  // RF04/RF08: Salva o progresso do jogador usando API REST (Substitui o formato antigo)
  static Future<void> salvarProgresso(String userId, int faseAtual, String ambienteAtualId) async {
    try {
      final url = Uri.parse('$_baseUrl/progresso/$userId.json');
      await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fase_atual": faseAtual,
          "ambiente_atual_id": ambienteAtualId,
          "ultima_atualizacao": DateTime.now().millisecondsSinceEpoch,
        }),
      );
    } catch (e) {
      debugPrint("Erro ao salvar progresso via REST: $e");
    }
  }

  // RF03: Busca as informações de um ambiente (Coordenadas, Imagem, Som) via REST
  static Future<Map<String, dynamic>?> obterAmbiente(String ambienteId) async {
    try {
      final url = Uri.parse('$_baseUrl/ambientes/$ambienteId.json');
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != 'null') {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao obter ambiente via REST: $e");
      return null;
    }
  }

  // RF05: Busca a árvore de diálogos e múltiplas escolhas de um ambiente via REST
  static Future<Map<String, dynamic>?> obterInteracao(String interacaoId) async {
    try {
      final url = Uri.parse('$_baseUrl/interacoes/$interacaoId.json');
      final response = await http.get(url);
      if (response.statusCode == 200 && response.body != 'null') {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao obter interacao via REST: $e");
      return null;
    }
  }
}
