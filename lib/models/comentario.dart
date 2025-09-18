class Comentario {
  final String id;
  final String receitaId;
  final String autor;
  final String conteudo;
  final DateTime dataCriacao;
  final int? avaliacao; // 1-5 estrelas

  Comentario({
    required this.id,
    required this.receitaId,
    required this.autor,
    required this.conteudo,
    required this.dataCriacao,
    this.avaliacao,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'] as String,
      receitaId: json['receitaId'] as String,
      autor: json['autor'] as String,
      conteudo: json['conteudo'] as String,
      dataCriacao: DateTime.parse(json['dataCriacao'] as String),
      avaliacao: json['avaliacao'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receitaId': receitaId,
      'autor': autor,
      'conteudo': conteudo,
      'dataCriacao': dataCriacao.toIso8601String(),
      'avaliacao': avaliacao,
    };
  }
}

