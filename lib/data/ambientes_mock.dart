import '../models/ambiente.dart';

final List<Ambiente> ambientes = [

  Ambiente(
    id: "1",
    nome: "Auditório",
    descricao: "Local onde o apagão começou.",
    latitude: -22.832833,
    longitude: -47.052566,
    raioMetros: 30,
    desbloqueado: false,
  ),

  Ambiente(
    id: "2",
    nome: "Biblioteca",
    descricao: "Lugar silencioso, onde a bibliotecária trabalha.",
    latitude: -22.833897,
    longitude: -47.051852,
    raioMetros: 30,
    desbloqueado: false,
  ),

  Ambiente(
    id: "3",
    nome: "Praça de Alimentação",
    descricao: "Lugar geralmente cheio, onde as conversas se espalham.",
    latitude: -22.833096,
    longitude:  -47.052297,
    raioMetros: 50,
    desbloqueado: false,
  ),

  Ambiente(
    id: "4",
    nome: "Centro de Estudos Africanos e Afro-Brasileiros",
    descricao: "Algo de estranho aconteceu aqui, dizem que o professor de história viu algo suspeito.",
    latitude:  -22.833763,
    longitude: -47.051906,
    raioMetros: 30,
    desbloqueado: false,
  ),

  Ambiente(
    id: "5",
    nome: "Manacás",
    descricao: "Deve ter algum aparelho que possa ter causado o apagão, ou alguém que tenha visto algo.",
    latitude: -22.832446,
    longitude: -47.051259,
    raioMetros: 50,
    desbloqueado: false,
  )
];
