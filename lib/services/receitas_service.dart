import 'package:flutter/foundation.dart';
import '../models/receita.dart';
import '../models/comentario.dart';

class ReceitasService extends ChangeNotifier {
  static final ReceitasService _instance = ReceitasService._internal();
  factory ReceitasService() => _instance;
  ReceitasService._internal();

  final List<Receita> _receitas = [
    // Receitas fake pré-carregadas
    Receita(
      id: '1',
      titulo: 'Brigadeiro Tradicional',
      descricao: 'Delicioso brigadeiro cremoso feito com leite condensado e chocolate em pó.',
      ingredientes: [
        '1 lata de leite condensado',
        '1 colher de sopa de margarina',
        '3 colheres de sopa de chocolate em pó',
        'Chocolate granulado para cobertura'
      ],
      modoPreparo: '''1. Em uma panela, misture o leite condensado, a margarina e o chocolate em pó.
2. Cozinhe em fogo médio, mexendo sempre, até desgrudar do fundo da panela.
3. Deixe esfriar e faça bolinhas com as mãos untadas de margarina.
4. Passe no chocolate granulado e sirva em forminhas.''',
      tempoPreparo: '20 minutos',
      porcoes: 20,
      dataCriacao: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Receita(
      id: '2',
      titulo: 'Bolo de Chocolate',
      descricao: 'Bolo fofinho e saboroso de chocolate, perfeito para qualquer ocasião.',
      ingredientes: [
        '2 xícaras de farinha de trigo',
        '1 xícara de chocolate em pó',
        '2 xícaras de açúcar',
        '1 xícara de óleo',
        '4 ovos',
        '2 xícaras de água morna',
        '1 colher de sopa de fermento em pó'
      ],
      modoPreparo: '''1. Bata os ovos com o açúcar até ficar cremoso.
2. Adicione o óleo e continue batendo.
3. Misture a farinha, o chocolate em pó e o fermento.
4. Adicione os ingredientes secos alternando com a água.
5. Despeje em forma untada e asse por 40 minutos a 180°C.''',
      tempoPreparo: '1 hora',
      porcoes: 12,
      dataCriacao: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Receita(
      id: '3',
      titulo: 'Coxinha de Frango',
      descricao: 'Coxinha crocante com recheio cremoso de frango desfiado.',
      ingredientes: [
        '500g de peito de frango',
        '2 xícaras de farinha de trigo',
        '2 xícaras de caldo de galinha',
        '2 colheres de sopa de margarina',
        '1 cebola picada',
        '2 dentes de alho',
        'Farinha de rosca para empanar',
        'Óleo para fritar'
      ],
      modoPreparo: '''1. Cozinhe e desfie o frango, tempere com cebola e alho.
2. Ferva o caldo com margarina e adicione a farinha mexendo até formar uma massa.
3. Abra a massa, recheie com frango e modele as coxinhas.
4. Passe na farinha de rosca e frite até dourar.''',
      tempoPreparo: '2 horas',
      porcoes: 30,
      dataCriacao: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // Lista de comentários fake
  final List<Comentario> _comentarios = [
    Comentario(
      id: '1',
      receitaId: '1',
      usuarioId: 'user1',
      autor: 'Maria Silva',
      conteudo: 'Receita maravilhosa! Ficou exatamente como esperado. Recomendo!',
      dataCriacao: DateTime.now().subtract(const Duration(hours: 2)),
      avaliacao: 5,
    ),
    Comentario(
      id: '2',
      receitaId: '1',
      usuarioId: 'user2',
      autor: 'João Santos',
      conteudo: 'Muito fácil de fazer e ficou delicioso. Minha família adorou!',
      dataCriacao: DateTime.now().subtract(const Duration(days: 1)),
      avaliacao: 4,
    ),
    Comentario(
      id: '3',
      receitaId: '2',
      usuarioId: 'user3',
      autor: 'Ana Costa',
      conteudo: 'Bolo ficou fofinho e saboroso. Vou fazer novamente!',
      dataCriacao: DateTime.now().subtract(const Duration(hours: 5)),
      avaliacao: 5,
    ),
  ];

  List<Receita> get receitas => List.unmodifiable(_receitas);

  void adicionarReceita(Receita receita) {
    _receitas.add(receita);
    notifyListeners();
  }

  void removerReceita(String id) {
    _receitas.removeWhere((receita) => receita.id == id);
    notifyListeners();
  }

  void atualizarReceita(Receita receitaAtualizada) {
    final index = _receitas.indexWhere((receita) => receita.id == receitaAtualizada.id);
    if (index != -1) {
      _receitas[index] = receitaAtualizada;
      notifyListeners();
    }
  }

  Receita? buscarReceitaPorId(String id) {
    try {
      return _receitas.firstWhere((receita) => receita.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Receita> buscarReceitasPorTitulo(String titulo) {
    return _receitas
        .where((receita) => receita.titulo.toLowerCase().contains(titulo.toLowerCase()))
        .toList();
  }

  void limparTodasReceitas() {
    _receitas.clear();
    notifyListeners();
  }

  // Métodos para comentários
  List<Comentario> getComentariosPorReceita(String receitaId) {
    return _comentarios
        .where((comentario) => comentario.receitaId == receitaId)
        .toList()
      ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
  }

  void adicionarComentario(Comentario comentario) {
    _comentarios.add(comentario);
    notifyListeners();
  }

  void removerComentario(String id) {
    _comentarios.removeWhere((comentario) => comentario.id == id);
    notifyListeners();
  }

  // Métodos para receitas relacionadas
  List<Receita> getReceitasRelacionadas(String receitaId, {int limite = 3}) {
    final receitaAtual = buscarReceitaPorId(receitaId);
    if (receitaAtual == null) return [];

    // Simula receitas relacionadas baseadas em palavras-chave similares
    final palavrasChave = receitaAtual.titulo.toLowerCase().split(' ');
    
    return _receitas
        .where((receita) => receita.id != receitaId)
        .where((receita) {
          final tituloReceita = receita.titulo.toLowerCase();
          return palavrasChave.any((palavra) => tituloReceita.contains(palavra));
        })
        .take(limite)
        .toList();
  }
}
