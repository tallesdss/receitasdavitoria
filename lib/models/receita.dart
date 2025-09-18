class Receita {
  final String id;
  final String titulo;
  final String descricao;
  final List<String> ingredientes;
  final String modoPreparo;
  final String tempoPreparo;
  final int porcoes;
  final String? urlImagem;
  final DateTime dataCriacao;

  Receita({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.ingredientes,
    required this.modoPreparo,
    required this.tempoPreparo,
    required this.porcoes,
    this.urlImagem,
    required this.dataCriacao,
  });

  // Converter para Map (para facilitar futuras integrações com APIs)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'ingredientes': ingredientes,
      'modoPreparo': modoPreparo,
      'tempoPreparo': tempoPreparo,
      'porcoes': porcoes,
      'urlImagem': urlImagem,
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  // Criar a partir de Map
  factory Receita.fromMap(Map<String, dynamic> map) {
    return Receita(
      id: map['id'],
      titulo: map['titulo'],
      descricao: map['descricao'],
      ingredientes: List<String>.from(map['ingredientes']),
      modoPreparo: map['modoPreparo'],
      tempoPreparo: map['tempoPreparo'],
      porcoes: map['porcoes'],
      urlImagem: map['urlImagem'],
      dataCriacao: DateTime.parse(map['dataCriacao']),
    );
  }

  // Cópia com modificações
  Receita copyWith({
    String? id,
    String? titulo,
    String? descricao,
    List<String>? ingredientes,
    String? modoPreparo,
    String? tempoPreparo,
    int? porcoes,
    String? urlImagem,
    DateTime? dataCriacao,
  }) {
    return Receita(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      ingredientes: ingredientes ?? this.ingredientes,
      modoPreparo: modoPreparo ?? this.modoPreparo,
      tempoPreparo: tempoPreparo ?? this.tempoPreparo,
      porcoes: porcoes ?? this.porcoes,
      urlImagem: urlImagem ?? this.urlImagem,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}
