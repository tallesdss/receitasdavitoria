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
      body: CustomScrollView(
        slivers: [
          // AppBar moderno com gradiente
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            // Avatar do usuário
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.textOnPrimary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.textOnPrimary.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.textOnPrimary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Olá, Vitória!',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  Text(
                                    'Receitas da Vitória',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textOnPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Botão de notificação
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.textOnPrimary,
                                  size: 22,
                                ),
                                onPressed: () {},
                                tooltip: 'Notificações',
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botão de logout
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.logout,
                                  color: AppColors.textOnPrimary,
                                  size: 22,
                                ),
                                onPressed: _logout,
                                tooltip: 'Sair',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Barra de pesquisa
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowMedium,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Procure por receitas...',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.all(8),
                            child: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _buscarReceitas('');
                              },
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              Icons.tune,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  style: AppTextStyles.bodyLarge,
                  onChanged: _buscarReceitas,
                ),
              ),
            ),
          ),
          
          // Categorias rápidas
          SliverToBoxAdapter(
            child: _buildCategoriasRapidas(),
          ),
          
          // Lista de receitas
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: _receitasFiltradas.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final receita = _receitasFiltradas[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildRecipeCard(receita),
                        );
                      },
                      childCount: _receitasFiltradas.length,
                    ),
                  ),
          ),
          
          // Espaçamento final
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navegarParaCriarReceita,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        tooltip: 'Nova receita',
        icon: const Icon(Icons.add),
        label: Text(
          'Nova receita',
          style: AppTextStyles.buttonSmall.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriasRapidas() {
    final categorias = [
      {'icon': Icons.cake, 'label': 'Doces', 'color': AppColors.secondary},
      {'icon': Icons.restaurant, 'label': 'Massas', 'color': AppColors.accent},
      {'icon': Icons.local_pizza, 'label': 'Salgados', 'color': AppColors.warning},
      {'icon': Icons.coffee, 'label': 'Bebidas', 'color': AppColors.success},
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Receitas do momento',
                  style: AppTextStyles.h4.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Ver todas',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: (categoria['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (categoria['color'] as Color).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          categoria['icon'] as IconData,
                          color: categoria['color'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categoria['label'] as String,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navegarParaDetalhe(receita),
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da receita (placeholder com gradiente)
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Stack(
                children: [
                  // Placeholder da imagem
                  Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                  // Badge de tempo
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.textOnPrimary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
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
                  ),
                ],
              ),
            ),
            
            // Conteúdo do card
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    receita.titulo,
                    style: AppTextStyles.h5.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Descrição
                  Text(
                    receita.descricao,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Informações adicionais
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.restaurant,
                        label: '${receita.porcoes} porções',
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.list_alt,
                        label: '${receita.ingredientes.length} ingredientes',
                        color: AppColors.success,
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
