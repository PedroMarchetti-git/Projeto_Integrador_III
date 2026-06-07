// Substitua pela URL exata do seu projeto Firebase
const BASE_URL = "https://pi3-rpg-default-rtdb.firebaseio.com";

export const RPG_API = {
  // RF04 e RF08: Buscar o progresso atual do jogador (Salvar e Continuar)
  async obterProgresso(jogadorId) {
    const response = await fetch(`${BASE_URL}/progresso/${jogadorId}.json`);
    return await response.json();
  },

  // RF03 e RF07: Buscar os dados e trilha sonora do ambiente geolocalizado
  async obterAmbiente(ambienteId) {
    const response = await fetch(`${BASE_URL}/ambientes/${ambienteId}.json`);
    return await response.json();
  },

  // RF05: Buscar diálogos interativos com múltiplas escolhas
  async obterInteracao(interacaoId) {
    const response = await fetch(`${BASE_URL}/interacoes/${interacaoId}.json`);
    return await response.json();
  },

  // RF04 e RF08: Atualizar o progresso do jogador (Salvar jogo)
  async atualizarProgresso(jogadorId, novaFase, novoAmbienteId) {
    const response = await fetch(`${BASE_URL}/progresso/${jogadorId}.json`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        fase_atual: novaFase,
        ambiente_atual_id: novoAmbienteId,
        ultima_atualizacao: Date.now()
      })
    });
    return await response.json();
  }
};
