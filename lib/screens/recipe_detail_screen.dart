import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/responsive_breakpoints.dart';
import '../models/receita.dart';
import '../models/comentario.dart';
import '../providers/receitas_provider.dart';

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
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  bool _isFavorite = false;
  List<Comentario> _comentarios = [];
  List<Receita> _receitasRelacionadas = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    final receitasProvider = Provider.of<ReceitasProvider>(context, listen: false);

    // Carregar comentários
    _comentarios = await receitasProvider.getComentariosByReceita(widget.receita.id);

    // Carregar favoritos
    final favoritosIds = await receitasProvider.getFavoritosIds();
    _isFavorite = favoritosIds.contains(widget.receita.id);

    // Por enquanto, receitas relacionadas será uma lista vazia
    _receitasRelacionadas = [];

    setState(() {});
  }

  void _navegarParaTodasReceitas() {
    Navigator.pushNamed(context, '/home');
  }

  void _toggleFavorite() async {
    final receitasProvider = Provider.of<ReceitasProvider>(context, listen: false);

    final success = await receitasProvider.toggleFavorito(widget.receita.id);

    if (!mounted) return;

    if (success) {
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao atualizar favorito'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            onPressed: () async {
              final receitasProvider = Provider.of<ReceitasProvider>(context, listen: false);
              final success = await receitasProvider.deleteReceita(widget.receita.id);

              if (!mounted) return;

              if (success) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Fechar dialog
                    Navigator.of(context).pop(); // Voltar para a lista
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receita excluída com sucesso!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                });
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.of(context).pop(); // Fechar dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao excluir receita'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                });
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showAddCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar comentário'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _autorController,
              decoration: const InputDecoration(
                labelText: 'Seu nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioController,
              decoration: const InputDecoration(
                labelText: 'Comentário',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _autorController.clear();
              _comentarioController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (_autorController.text.isNotEmpty && _comentarioController.text.isNotEmpty) {
                final receitasProvider = Provider.of<ReceitasProvider>(context, listen: false);

                final success = await receitasProvider.createComentario(
                  widget.receita.id,
                  _comentarioController.text,
                  // avaliacao: 5, // Por enquanto não implementei avaliação
                );

                if (!mounted) return;

                if (success) {
                  // Recarregar comentários
                  _comentarios = await receitasProvider.getComentariosByReceita(widget.receita.id);
                  setState(() {});

                  _autorController.clear();
                  _comentarioController.clear();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Comentário adicionado!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  });
                } else {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Erro ao adicionar comentário'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  });
                }
              }
            },
            child: const Text('Adicionar'),
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
          // AppBar expansível com imagem modernizado
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem de fundo com gradiente
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
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
                  // Overlay gradiente para melhor legibilidade
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Título posicionado na parte inferior
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.receita.titulo,
                          style: AppTextStyles.h2.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                                color: Colors.black.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildHeaderChip(
                              icon: Icons.access_time,
                              label: widget.receita.tempoPreparo,
                            ),
                            const SizedBox(width: 12),
                            _buildHeaderChip(
                              icon: Icons.restaurant,
                              label: '${widget.receita.porcoes} porções',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Botão de favorito estilizado
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? AppColors.error : Colors.white,
                    size: 24,
                  ),
                  onPressed: _toggleFavorite,
                  tooltip: _isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                ),
              ),
              // Menu de opções estilizado
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24,
                  ),
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
              ),
            ],
          ),
          
          // Conteúdo da receita
          SliverToBoxAdapter(
            child: ResponsiveContainer(
              child: ResponsiveBuilder(
                builder: (context, deviceType) {
                  return _buildRecipeContent(context, deviceType);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context, DeviceType deviceType) {
    if (deviceType == DeviceType.desktop) {
      // Layout de duas colunas para desktop
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna esquerda - Informações principais
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCards(),
                const SizedBox(height: 32),
                _buildSection(
                  title: 'Descrição',
                  child: Text(
                    widget.receita.descricao,
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
                const SizedBox(height: 24),
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
                _buildSection(
                  title: 'Modo de preparo',
                  child: Text(
                    widget.receita.modoPreparo,
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
          // Coluna direita - Comentários e receitas relacionadas
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildComentariosSection(),
                const SizedBox(height: 32),
                _buildVejaMaisReceitasSection(),
              ],
            ),
          ),
        ],
      );
    } else {
      // Layout vertical para mobile/tablet
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCards(),
          const SizedBox(height: 32),
          _buildSection(
            title: 'Descrição',
            child: Text(
              widget.receita.descricao,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
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
          _buildSection(
            title: 'Modo de preparo',
            child: Text(
              widget.receita.modoPreparo,
              style: AppTextStyles.bodyLarge,
            ),
          ),
          const SizedBox(height: 24),
          _buildComentariosSection(),
          const SizedBox(height: 24),
          _buildVejaMaisReceitasSection(),
          const SizedBox(height: 32),
        ],
      );
    }
  }

  Widget _buildDefaultImage() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 80,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.desktop) {
          // Grid 3x1 para desktop com mais espaço
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Tempo',
                      value: widget.receita.tempoPreparo,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.restaurant,
                      title: 'Porções',
                      value: '${widget.receita.porcoes}',
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.list_alt,
                      title: 'Ingredientes',
                      value: '${widget.receita.ingredientes.length}',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(child: SizedBox()), // Espaço vazio para manter alinhamento
                ],
              ),
            ],
          );
        } else {
          // Layout original para mobile/tablet
          return Container(
            margin: ResponsiveBreakpoints.getHorizontalPadding(context),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.access_time,
                    title: 'Tempo',
                    value: widget.receita.tempoPreparo,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.restaurant,
                    title: 'Porções',
                    value: '${widget.receita.porcoes}',
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.list_alt,
                    title: 'Ingredientes',
                    value: '${widget.receita.ingredientes.length}',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
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

  Widget _buildComentariosSection() {
    return _buildSection(
      title: 'Comentários (${_comentarios.length})',
      child: Column(
        children: [
          // Botão para adicionar comentário
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showAddCommentDialog,
              icon: const Icon(Icons.add_comment),
              label: const Text('Adicionar comentário'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de comentários
          if (_comentarios.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhum comentário ainda',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seja o primeiro a comentar!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._comentarios.map((comentario) => _buildComentarioCard(comentario)),
        ],
      ),
    );
  }

  Widget _buildComentarioCard(Comentario comentario) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  comentario.autor[0].toUpperCase(),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comentario.autor,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatarData(comentario.dataCriacao),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (comentario.avaliacao != null)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < comentario.avaliacao! ? Icons.star : Icons.star_border,
                      size: 16,
                      color: AppColors.warning,
                    );
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comentario.conteudo,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildVejaMaisReceitasSection() {
    return _buildSection(
      title: 'Veja mais receitas',
      child: Column(
        children: [
          // Lista de receitas relacionadas
          if (_receitasRelacionadas.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _receitasRelacionadas.length,
              itemBuilder: (context, index) {
                final receita = _receitasRelacionadas[index];
                return _buildReceitaRelacionadaCard(receita);
              },
            ),
          
          const SizedBox(height: 16),
          
          // Botão para ver todas as receitas
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navegarParaTodasReceitas,
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Ver todas as receitas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceitaRelacionadaCard(Receita receita) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(receita: receita),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Imagem da receita
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: receita.urlImagem != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          receita.urlImagem!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultImage();
                          },
                        ),
                      )
                    : _buildDefaultImage(),
              ),
              
              const SizedBox(width: 16),
              
              // Conteúdo do card
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receita.titulo,
                      style: AppTextStyles.h5.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      receita.descricao,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
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
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.restaurant,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${receita.porcoes} porções',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Ícone de navegação
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);
    
    if (diferenca.inDays > 0) {
      return '${diferenca.inDays} dia${diferenca.inDays > 1 ? 's' : ''} atrás';
    } else if (diferenca.inHours > 0) {
      return '${diferenca.inHours} hora${diferenca.inHours > 1 ? 's' : ''} atrás';
    } else if (diferenca.inMinutes > 0) {
      return '${diferenca.inMinutes} minuto${diferenca.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}
