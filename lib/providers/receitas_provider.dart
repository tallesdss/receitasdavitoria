import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../models/comentario.dart';
import '../services/database_service.dart';

class ReceitasProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Receita> _receitas = [];
  List<Map<String, dynamic>> _categorias = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategoriaId;
  String? _searchQuery;

  List<Receita> get receitas => _receitas;
  List<Map<String, dynamic>> get categorias => _categorias;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategoriaId => _selectedCategoriaId;
  String? get searchQuery => _searchQuery;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setSelectedCategoria(String? categoriaId) {
    _selectedCategoriaId = categoriaId;
    _loadReceitas();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _loadReceitas();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      _loadCategorias(),
      _loadReceitas(),
    ]);
  }

  Future<void> _loadCategorias() async {
    try {
      _categorias = await _databaseService.getCategorias();
      notifyListeners();
    } catch (error) {
      _setError('Erro ao carregar categorias: $error');
    }
  }

  Future<void> _loadReceitas() async {
    _setLoading(true);
    _setError(null);

    try {
      _receitas = await _databaseService.getReceitas(
        categoriaId: _selectedCategoriaId,
        searchQuery: _searchQuery,
      );
      _setLoading(false);
    } catch (error) {
      _setError('Erro ao carregar receitas: $error');
      _setLoading(false);
    }
  }

  Future<Receita?> getReceitaById(String id) async {
    try {
      return await _databaseService.getReceitaById(id);
    } catch (error) {
      _setError('Erro ao carregar receita: $error');
      return null;
    }
  }

  Future<bool> createReceita(Receita receita) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _databaseService.createReceita(receita);
      if (success) {
        await _loadReceitas(); // Recarregar lista
      }
      _setLoading(false);
      return success;
    } catch (error) {
      _setError('Erro ao criar receita: $error');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateReceita(Receita receita) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _databaseService.updateReceita(receita);
      if (success) {
        await _loadReceitas(); // Recarregar lista
      }
      _setLoading(false);
      return success;
    } catch (error) {
      _setError('Erro ao atualizar receita: $error');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteReceita(String receitaId) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _databaseService.deleteReceita(receitaId);
      if (success) {
        await _loadReceitas(); // Recarregar lista
      }
      _setLoading(false);
      return success;
    } catch (error) {
      _setError('Erro ao deletar receita: $error');
      _setLoading(false);
      return false;
    }
  }

  Future<List<Comentario>> getComentariosByReceita(String receitaId) async {
    try {
      return await _databaseService.getComentariosByReceita(receitaId);
    } catch (error) {
      _setError('Erro ao carregar comentários: $error');
      return [];
    }
  }

  Future<bool> createComentario(String receitaId, String conteudo, {int? avaliacao}) async {
    try {
      return await _databaseService.createComentario(receitaId, conteudo, avaliacao: avaliacao);
    } catch (error) {
      _setError('Erro ao criar comentário: $error');
      return false;
    }
  }

  Future<List<String>> getFavoritosIds() async {
    try {
      return await _databaseService.getFavoritosIds();
    } catch (error) {
      _setError('Erro ao carregar favoritos: $error');
      return [];
    }
  }

  Future<bool> toggleFavorito(String receitaId) async {
    try {
      return await _databaseService.toggleFavorito(receitaId);
    } catch (error) {
      _setError('Erro ao atualizar favorito: $error');
      return false;
    }
  }

  Future<List<Receita>> getMinhasReceitas() async {
    try {
      return await _databaseService.getMinhasReceitas();
    } catch (error) {
      _setError('Erro ao carregar minhas receitas: $error');
      return [];
    }
  }

  // Método para recarregar dados
  Future<void> refresh() async {
    await loadInitialData();
  }
}
