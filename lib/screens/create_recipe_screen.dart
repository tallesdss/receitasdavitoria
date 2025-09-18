import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/receita.dart';
import '../services/receitas_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final ReceitasService _receitasService = ReceitasService();
  
  // Controladores dos campos
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _modoPreparoController = TextEditingController();
  final _tempoPreparoController = TextEditingController();
  final _porcoesController = TextEditingController();
  
  // Lista de ingredientes
  final List<TextEditingController> _ingredientesControllers = [
    TextEditingController(),
  ];
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _modoPreparoController.dispose();
    _tempoPreparoController.dispose();
    _porcoesController.dispose();
    
    for (final controller in _ingredientesControllers) {
      controller.dispose();
    }
    
    super.dispose();
  }

  void _adicionarIngrediente() {
    setState(() {
      _ingredientesControllers.add(TextEditingController());
    });
  }

  void _removerIngrediente(int index) {
    if (_ingredientesControllers.length > 1) {
      setState(() {
        _ingredientesControllers[index].dispose();
        _ingredientesControllers.removeAt(index);
      });
    }
  }

  Future<void> _selecionarImagem() async {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Selecionar Imagem',
                  style: AppTextStyles.h5.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageSourceButton(
                        icon: Icons.photo_camera,
                        label: 'Câmera',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildImageSourceButton(
                        icon: Icons.photo_library,
                        label: 'Galeria',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir seleção de imagem'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      Navigator.of(context).pop(); // Fechar o bottom sheet
      
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Imagem selecionada com sucesso!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao selecionar imagem'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _salvarReceita() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar ingredientes
    final ingredientes = _ingredientesControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (ingredientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um ingrediente'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Criar nova receita
      final novaReceita = Receita(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        ingredientes: ingredientes,
        modoPreparo: _modoPreparoController.text.trim(),
        tempoPreparo: _tempoPreparoController.text.trim(),
        porcoes: int.parse(_porcoesController.text.trim()),
        dataCriacao: DateTime.now(),
      );

      // Simular delay de salvamento
      await Future.delayed(const Duration(seconds: 1));

      // Salvar no service
      _receitasService.adicionarReceita(novaReceita);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita criada com sucesso!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao criar receita. Tente novamente.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Nova Receita',
          style: AppTextStyles.h4.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isLoading)
            Container(
              margin: const EdgeInsets.all(16),
              width: 24,
              height: 24,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          else
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: ElevatedButton(
                onPressed: _salvarReceita,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Salvar',
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com imagem placeholder/preview
              Container(
                height: 200,
                decoration: BoxDecoration(
                  gradient: _selectedImage == null ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    // Imagem selecionada ou placeholder
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(
                          File(_selectedImage!.path),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 48,
                              color: AppColors.textOnPrimary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adicionar foto',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnPrimary.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Overlay para editar imagem
                    if (_selectedImage != null)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    
                    // Botão para selecionar/trocar imagem
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _selecionarImagem,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              // Título
              _buildSectionTitle('Informações Básicas'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da receita',
                  hintText: 'Ex: Bolo de chocolate',
                  prefixIcon: Icon(Icons.title),
                ),
                style: AppTextStyles.bodyLarge,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o título da receita';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva brevemente sua receita',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                style: AppTextStyles.bodyLarge,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite uma descrição';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Informações básicas em cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _tempoPreparoController,
                        decoration: const InputDecoration(
                          labelText: 'Tempo de preparo',
                          hintText: 'Ex: 30 min',
                          prefixIcon: Icon(Icons.access_time),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        style: AppTextStyles.bodyLarge,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite o tempo';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _porcoesController,
                        decoration: const InputDecoration(
                          labelText: 'Porções',
                          hintText: 'Ex: 4',
                          prefixIcon: Icon(Icons.restaurant),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        ),
                        style: AppTextStyles.bodyLarge,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite as porções';
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return 'Digite um número';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Ingredientes
              _buildSectionTitle('Ingredientes'),
              const SizedBox(height: 16),
              
              ...List.generate(_ingredientesControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ingredientesControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Ingrediente ${index + 1}',
                            hintText: 'Ex: 2 xícaras de farinha',
                          ),
                        ),
                      ),
                      if (_ingredientesControllers.length > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColors.error,
                          onPressed: () => _removerIngrediente(index),
                        ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 8),
              
              OutlinedButton.icon(
                onPressed: _adicionarIngrediente,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar ingrediente'),
              ),
              
              const SizedBox(height: 24),
              
              // Modo de preparo
              _buildSectionTitle('Modo de Preparo'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _modoPreparoController,
                decoration: const InputDecoration(
                  labelText: 'Instruções de preparo',
                  hintText: 'Descreva passo a passo como preparar a receita...',
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o modo de preparo';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Botão de salvar
              ElevatedButton(
                onPressed: _isLoading ? null : _salvarReceita,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textOnPrimary,
                          ),
                        ),
                      )
                    : const Text('Criar receita'),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}
