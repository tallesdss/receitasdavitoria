import 'package:flutter/material.dart';
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
        title: const Text('Nova Receita'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _salvarReceita,
              child: Text(
                'Salvar',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da receita',
                  hintText: 'Ex: Bolo de chocolate',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o título da receita';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Descrição
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva brevemente sua receita',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite uma descrição';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Informações básicas
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tempoPreparoController,
                      decoration: const InputDecoration(
                        labelText: 'Tempo de preparo',
                        hintText: 'Ex: 30 minutos',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite o tempo';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _porcoesController,
                      decoration: const InputDecoration(
                        labelText: 'Porções',
                        hintText: 'Ex: 4',
                      ),
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
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Ingredientes
              Text(
                'Ingredientes',
                style: AppTextStyles.h5,
              ),
              const SizedBox(height: 12),
              
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
              Text(
                'Modo de preparo',
                style: AppTextStyles.h5,
              ),
              const SizedBox(height: 12),
              
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
}
