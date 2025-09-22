import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import '../models/receita.dart';
import '../models/comentario.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger('DatabaseService');

  // =============================================================================
  // RECEITAS
  // =============================================================================

  Future<List<Receita>> getReceitas({String? categoriaId, String? searchQuery}) async {
    try {
      // Query básica das receitas sem filtros por enquanto
      final response = await _supabase
          .from('receitas')
          .select('''
            *,
            usuarios(nome, email),
            categorias(id, nome, cor, icone)
          ''')
          .order('data_criacao', ascending: false);

      // Para cada receita, buscar ingredientes e passos separadamente
      final receitasCompletas = <Receita>[];

      for (final receitaJson in response) {
        final receitaId = receitaJson['id'];

        // Buscar ingredientes
        final ingredientesResponse = await _supabase
            .from('ingredientes')
            .select('nome, quantidade, unidade')
            .eq('receita_id', receitaId)
            .order('ordem');

        final ingredientes = ingredientesResponse
            .map((ing) => '${ing['quantidade'] ?? ''} ${ing['unidade'] ?? ''} ${ing['nome']}'.trim())
            .toList();

        // Buscar passos de preparo
        final passosResponse = await _supabase
            .from('passos_preparo')
            .select('passo')
            .eq('receita_id', receitaId)
            .order('ordem');

        final modoPreparo = passosResponse
            .map((passo) => passo['passo'] as String)
            .join('\n\n');

        final receitaData = Map<String, dynamic>.from(receitaJson);
        receitaData['ingredientes'] = ingredientes;
        receitaData['modoPreparo'] = modoPreparo;

        receitasCompletas.add(Receita.fromMap(receitaData));
      }

      return receitasCompletas;
    } catch (error) {
      _logger.warning('Erro ao buscar receitas: $error');
      return [];
    }
  }

  Future<Receita?> getReceitaById(String id) async {
    try {
      final response = await _supabase
          .from('receitas')
          .select('''
            *,
            usuarios(nome, email),
            categorias(id, nome, cor, icone),
            ingredientes(id, nome, quantidade, unidade, ordem),
            passos_preparo(id, passo, ordem, tempo_estimado),
            comentarios(
              id,
              conteudo,
              avaliacao,
              data_criacao,
              usuarios(nome)
            )
          ''')
          .eq('id', id)
          .single();

      final receitaData = Map<String, dynamic>.from(response);
      receitaData['ingredientes'] = (response['ingredientes'] as List<dynamic>?)
          ?.map((ing) => '${ing['quantidade'] ?? ''} ${ing['unidade'] ?? ''} ${ing['nome']}'.trim())
          .toList() ?? [];

      final passos = (response['passos_preparo'] as List<dynamic>?)
          ?.map((p) => p['passo'] as String)
          .toList() ?? [];
      receitaData['modoPreparo'] = passos.join('\n\n');

      return Receita.fromMap(receitaData);
    } catch (error) {
      _logger.warning('Erro ao buscar receita: $error');
      return null;
    }
  }

  Future<bool> createReceita(Receita receita) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final receitaData = {
        'usuario_id': user.id,
        'titulo': receita.titulo,
        'descricao': receita.descricao,
        'tempo_preparo': receita.tempoPreparo,
        'porcoes': receita.porcoes,
        'url_imagem': receita.urlImagem,
      };

      final response = await _supabase
          .from('receitas')
          .insert(receitaData)
          .select()
          .single();

      final receitaId = response['id'];

      // Inserir ingredientes
      if (receita.ingredientes.isNotEmpty) {
        final ingredientesData = receita.ingredientes.asMap().entries.map((entry) {
          final parts = entry.value.split(' ');
          String quantidade = '';
          String unidade = '';
          String nome = entry.value;

          if (parts.length >= 2) {
            quantidade = parts[0];
            if (parts.length >= 3) {
              unidade = parts[1];
              nome = parts.sublist(2).join(' ');
            } else {
              nome = parts[1];
            }
          }

          return {
            'receita_id': receitaId,
            'nome': nome,
            'quantidade': quantidade,
            'unidade': unidade,
            'ordem': entry.key,
          };
        }).toList();

        await _supabase.from('ingredientes').insert(ingredientesData);
      }

      // Inserir passos de preparo
      if (receita.modoPreparo.isNotEmpty) {
        final passos = receita.modoPreparo.split('\n\n');
        final passosData = passos.asMap().entries.map((entry) => {
          'receita_id': receitaId,
          'passo': entry.value.trim(),
          'ordem': entry.key + 1,
        }).toList();

        await _supabase.from('passos_preparo').insert(passosData);
      }

      return true;
    } catch (error) {
      _logger.info('Erro ao criar receita: $error');
      return false;
    }
  }

  Future<bool> updateReceita(Receita receita) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final receitaData = {
        'titulo': receita.titulo,
        'descricao': receita.descricao,
        'tempo_preparo': receita.tempoPreparo,
        'porcoes': receita.porcoes,
        'url_imagem': receita.urlImagem,
        'data_atualizacao': DateTime.now().toIso8601String(),
      };

      await _supabase
          .from('receitas')
          .update(receitaData)
          .eq('id', receita.id)
          .eq('usuario_id', user.id);

      // Atualizar ingredientes (deletar e recriar)
      await _supabase.from('ingredientes').delete().eq('receita_id', receita.id);

      if (receita.ingredientes.isNotEmpty) {
        final ingredientesData = receita.ingredientes.asMap().entries.map((entry) {
          final parts = entry.value.split(' ');
          String quantidade = '';
          String unidade = '';
          String nome = entry.value;

          if (parts.length >= 2) {
            quantidade = parts[0];
            if (parts.length >= 3) {
              unidade = parts[1];
              nome = parts.sublist(2).join(' ');
            } else {
              nome = parts[1];
            }
          }

          return {
            'receita_id': receita.id,
            'nome': nome,
            'quantidade': quantidade,
            'unidade': unidade,
            'ordem': entry.key,
          };
        }).toList();

        await _supabase.from('ingredientes').insert(ingredientesData);
      }

      // Atualizar passos de preparo
      await _supabase.from('passos_preparo').delete().eq('receita_id', receita.id);

      if (receita.modoPreparo.isNotEmpty) {
        final passos = receita.modoPreparo.split('\n\n');
        final passosData = passos.asMap().entries.map((entry) => {
          'receita_id': receita.id,
          'passo': entry.value.trim(),
          'ordem': entry.key + 1,
        }).toList();

        await _supabase.from('passos_preparo').insert(passosData);
      }

      return true;
    } catch (error) {
      _logger.info('Erro ao atualizar receita: $error');
      return false;
    }
  }

  Future<bool> deleteReceita(String receitaId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase
          .from('receitas')
          .delete()
          .eq('id', receitaId)
          .eq('usuario_id', user.id);

      return true;
    } catch (error) {
      _logger.info('Erro ao deletar receita: $error');
      return false;
    }
  }

  // =============================================================================
  // COMENTÁRIOS
  // =============================================================================

  Future<List<Comentario>> getComentariosByReceita(String receitaId) async {
    try {
      final response = await _supabase
          .from('comentarios')
          .select('''
            *,
            usuarios(nome, email)
          ''')
          .eq('receita_id', receitaId)
          .order('data_criacao', ascending: false);

      return response.map<Comentario>((json) {
        final comentarioData = Map<String, dynamic>.from(json);
        comentarioData['autor'] = json['usuarios']['nome'] ?? json['usuarios']['email'];
        return Comentario.fromJson(comentarioData);
      }).toList();
    } catch (error) {
      _logger.info('Erro ao buscar comentários: $error');
      return [];
    }
  }

  Future<bool> createComentario(String receitaId, String conteudo, {int? avaliacao}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final comentarioData = {
        'receita_id': receitaId,
        'usuario_id': user.id,
        'conteudo': conteudo,
        'avaliacao': avaliacao,
      };

      await _supabase.from('comentarios').insert(comentarioData);
      return true;
    } catch (error) {
      _logger.info('Erro ao criar comentário: $error');
      return false;
    }
  }

  // =============================================================================
  // FAVORITOS
  // =============================================================================

  Future<List<String>> getFavoritosIds() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('favoritos')
          .select('receita_id')
          .eq('usuario_id', user.id);

      return response.map<String>((item) => item['receita_id'] as String).toList();
    } catch (error) {
      _logger.info('Erro ao buscar favoritos: $error');
      return [];
    }
  }

  Future<bool> toggleFavorito(String receitaId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Verificar se já é favorito
      final existing = await _supabase
          .from('favoritos')
          .select('id')
          .eq('usuario_id', user.id)
          .eq('receita_id', receitaId)
          .maybeSingle();

      if (existing != null) {
        // Remover dos favoritos
        await _supabase
            .from('favoritos')
            .delete()
            .eq('usuario_id', user.id)
            .eq('receita_id', receitaId);
        return false; // Não é mais favorito
      } else {
        // Adicionar aos favoritos
        await _supabase.from('favoritos').insert({
          'usuario_id': user.id,
          'receita_id': receitaId,
        });
        return true; // Agora é favorito
      }
    } catch (error) {
      _logger.info('Erro ao toggle favorito: $error');
      return false;
    }
  }

  // =============================================================================
  // CATEGORIAS
  // =============================================================================

  Future<List<Map<String, dynamic>>> getCategorias() async {
    try {
      final response = await _supabase
          .from('categorias')
          .select('*')
          .order('nome');

      return response.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
    } catch (error) {
      _logger.info('Erro ao buscar categorias: $error');
      return [];
    }
  }

  // =============================================================================
  // RECEITAS DO USUÁRIO
  // =============================================================================

  Future<List<Receita>> getMinhasReceitas() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];

      final response = await _supabase
          .from('receitas')
          .select('''
            *,
            usuarios(nome, email),
            categorias(id, nome, cor, icone),
            ingredientes(id, nome, quantidade, unidade, ordem),
            passos_preparo(id, passo, ordem, tempo_estimado)
          ''')
          .eq('usuario_id', user.id)
          .order('data_criacao', ascending: false);

      return response.map<Receita>((json) {
        final receitaData = Map<String, dynamic>.from(json);
        receitaData['ingredientes'] = (json['ingredientes'] as List<dynamic>?)
            ?.map((ing) => '${ing['quantidade'] ?? ''} ${ing['unidade'] ?? ''} ${ing['nome']}'.trim())
            .toList() ?? [];

        final passos = (json['passos_preparo'] as List<dynamic>?)
            ?.map((p) => p['passo'] as String)
            .toList() ?? [];
        receitaData['modoPreparo'] = passos.join('\n\n');

        return Receita.fromMap(receitaData);
      }).toList();
    } catch (error) {
      _logger.info('Erro ao buscar minhas receitas: $error');
      return [];
    }
  }

  // =============================================================================
  // MÉTODOS DE SETUP (EXECUTAR APENAS UMA VEZ)
  // =============================================================================

  Future<void> setupDatabase() async {
    try {
      // Este método pode ser usado para executar o script SQL via API
      // Por enquanto, execute o script manualmente no painel do Supabase
      _logger.info('Execute o script supabase_setup.sql no painel do Supabase');
    } catch (error) {
      _logger.info('Erro no setup do banco: $error');
    }
  }
}
