import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/receita.dart';
import '../services/receitas_service.dart';
import 'recipe_detail_screen.dart';
import 'create_recipe_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReceitasService _receitasService = ReceitasService();
  final TextEditingController _searchController = TextEditingController();
  List<Receita> _receitasFiltradas = [];

  @override
  void initState() {
    super.initState();
    _receitasFiltradas = _receitasService.receitas;
    _receitasService.addListener(_atualizarLista);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _receitasService.removeListener(_atualizarLista);
    super.dispose();
  }

  void _atualizarLista() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _receitasFiltradas = _receitasService.receitas;
      } else {
        _receitasFiltradas = _receitasService.buscarReceitasPorTitulo(_searchController.text);
      }
    });
  }

  void _buscarReceitas(String query) {
    setState(() {
      if (query.isEmpty) {
        _receitasFiltradas = _receitasService.receitas;
      } else {
        _receitasFiltradas = _receitasService.buscarReceitasPorTitulo(query);
      }
    });
  }

  void _navegarParaDetalhe(Receita receita) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(receita: receita),
      ),
    );
  }

  void _navegarParaCriarReceita() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateRecipeScreen(),
      ),
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Receitas da Vitória',
          style: AppTextStyles.h4,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar receitas...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _buscarReceitas('');
                        },
                      )
                    : null,
              ),
              onChanged: _buscarReceitas,
            ),
          ),
          
          // Lista de receitas
          Expanded(
            child: _receitasFiltradas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _receitasFiltradas.length,
                    itemBuilder: (context, index) {
                      final receita = _receitasFiltradas[index];
                      return _buildRecipeCard(receita);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navegarParaCriarReceita,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        tooltip: 'Nova receita',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Nenhuma receita encontrada'
                : 'Nenhuma receita encontrada para "${_searchController.text}"',
            style: AppTextStyles.h5.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isEmpty
                ? 'Comece criando sua primeira receita!'
                : 'Tente buscar por outro termo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navegarParaCriarReceita,
              icon: const Icon(Icons.add),
              label: const Text('Criar receita'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Receita receita) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navegarParaDetalhe(receita),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com título e tempo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      receita.titulo,
                      style: AppTextStyles.h5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          receita.tempoPreparo,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Descrição
              Text(
                receita.descricao,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Informações adicionais
              Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${receita.porcoes} porções',
                    style: AppTextStyles.labelSmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.list_alt,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${receita.ingredientes.length} ingredientes',
                    style: AppTextStyles.labelSmall,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
