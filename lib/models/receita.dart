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
      id: map['id']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      ingredientes: map['ingredientes'] is List 
          ? List<String>.from(map['ingredientes']) 
          : <String>[],
      modoPreparo: map['modoPreparo']?.toString() ?? map['modo_preparo']?.toString() ?? '',
      tempoPreparo: map['tempoPreparo']?.toString() ?? map['tempo_preparo']?.toString() ?? '',
      porcoes: map['porcoes'] is int ? map['porcoes'] : int.tryParse(map['porcoes']?.toString() ?? '0') ?? 0,
      urlImagem: map['urlImagem']?.toString() ?? map['url_imagem']?.toString(),
      dataCriacao: map['dataCriacao'] is String 
          ? DateTime.parse(map['dataCriacao'])
          : map['data_criacao'] is String
              ? DateTime.parse(map['data_criacao'])
              : DateTime.now(),
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
