class Comentario {
  final String id;
  final String receitaId;
  final String usuarioId;
  final String autor; // Nome do usuário
  final String conteudo;
  final DateTime dataCriacao;
  final int? avaliacao; // 1-5 estrelas

  Comentario({
    required this.id,
    required this.receitaId,
    required this.usuarioId,
    required this.autor,
    required this.conteudo,
    required this.dataCriacao,
    this.avaliacao,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'] as String,
      receitaId: json['receita_id'] as String,
      usuarioId: json['usuario_id'] as String,
      autor: json['autor'] as String? ?? 'Usuário',
      conteudo: json['conteudo'] as String,
      dataCriacao: DateTime.parse(json['data_criacao'] as String),
      avaliacao: json['avaliacao'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receita_id': receitaId,
      'usuario_id': usuarioId,
      'autor': autor,
      'conteudo': conteudo,
      'data_criacao': dataCriacao.toIso8601String(),
      'avaliacao': avaliacao,
    };
  }
}

