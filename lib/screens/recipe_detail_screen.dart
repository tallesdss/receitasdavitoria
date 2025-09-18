import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/receita.dart';
import '../services/receitas_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Receita receita;

  const RecipeDetailScreen({
    super.key,
    required this.receita,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final ReceitasService _receitasService = ReceitasService();
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Simulação de favorito (sempre false inicialmente)
    _isFavorite = false;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Receita adicionada aos favoritos!' : 'Receita removida dos favoritos!',
        ),
        backgroundColor: _isFavorite ? AppColors.success : AppColors.textSecondary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir receita'),
        content: const Text('Tem certeza que deseja excluir esta receita? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _receitasService.removerReceita(widget.receita.id);
              Navigator.of(context).pop(); // Fechar dialog
              Navigator.of(context).pop(); // Voltar para a lista
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Receita excluída com sucesso!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar expansível com imagem
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.receita.titulo,
                style: AppTextStyles.h5.copyWith(
                  color: AppColors.textOnPrimary,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: widget.receita.urlImagem != null
                    ? Image.network(
                        widget.receita.urlImagem!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultImage();
                        },
                      )
                    : _buildDefaultImage(),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.error : AppColors.textOnPrimary,
                ),
                onPressed: _toggleFavorite,
                tooltip: _isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Excluir receita'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Conteúdo da receita
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações básicas
                  _buildInfoCards(),
                  
                  const SizedBox(height: 24),
                  
                  // Descrição
                  _buildSection(
                    title: 'Descrição',
                    child: Text(
                      widget.receita.descricao,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Ingredientes
                  _buildSection(
                    title: 'Ingredientes',
                    child: Column(
                      children: widget.receita.ingredientes.map((ingrediente) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 8, right: 12),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  ingrediente,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Modo de preparo
                  _buildSection(
                    title: 'Modo de preparo',
                    child: Text(
                      widget.receita.modoPreparo,
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: AppColors.primary,
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 80,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.access_time,
            title: 'Tempo',
            value: widget.receita.tempoPreparo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.restaurant,
            title: 'Porções',
            value: '${widget.receita.porcoes}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.list_alt,
            title: 'Ingredientes',
            value: '${widget.receita.ingredientes.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
