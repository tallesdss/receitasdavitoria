# 🍳 Receitas da Vitória

Um aplicativo Flutter para gerenciar suas receitas favoritas, desenvolvido como template funcional com design system padronizado e navegação completa.

## ✨ Funcionalidades

- **Tela de Login**: Interface de autenticação fake (qualquer email/senha funciona)
- **Tela de Cadastro**: Formulário de registro com validação
- **Tela Inicial (Home)**: Lista de receitas com busca e filtros
- **Detalhes da Receita**: Visualização completa com ingredientes e modo de preparo
- **Criar Receita**: Formulário para adicionar novas receitas
- **Estado Local**: Armazenamento temporário usando ChangeNotifier

## 🎨 Design System

### Tipografia
- **Fonte**: Poppins (via Google Fonts)
- **Hierarquia**: H1 a H5, body texts, labels e botões
- **Pesos**: Regular, Medium, SemiBold e Bold

### Paleta de Cores
- **Primária**: #6C63FF (roxo)
- **Secundária**: #FF6B6B (coral)
- **Accent**: #4ECDC4 (turquesa)
- **Neutros**: Tons de cinza para texto e backgrounds
- **Status**: Success, Warning e Error

### Componentes
- Botões estilizados (Elevated, Outlined, Text)
- Campos de entrada padronizados
- Cards com sombras e bordas arredondadas
- AppBar e navegação consistentes

## 🏗️ Arquitetura

```
lib/
├── core/
│   └── theme/          # Design system (cores, tipografia, tema)
├── models/             # Modelos de dados (Receita)
├── screens/            # Telas do aplicativo
├── services/           # Gerenciamento de estado (ReceitasService)
└── main.dart          # Ponto de entrada do app
```

## 🚀 Como executar

1. Certifique-se de ter o Flutter instalado
2. Clone ou baixe o projeto
3. Execute os comandos:

```bash
flutter pub get
flutter run
```

## 🧪 Testes

Para executar os testes:

```bash
flutter test
flutter analyze
```

## 📱 Navegação

- **Login** → Home (após qualquer login)
- **Cadastro** → Home (após cadastro)
- **Home** → Detalhes da Receita
- **Home** → Criar Receita
- **Qualquer tela** → Logout → Login

## 🎯 Estado da Implementação

✅ **Concluído:**
- [x] Projeto Flutter configurado
- [x] Design System completo
- [x] Todas as telas implementadas
- [x] Navegação funcionando
- [x] Estado local com dados fake
- [x] Testes básicos
- [x] Análise de código sem erros

## 🔄 Funcionalidades Fake/Mock

- **Autenticação**: Qualquer email/senha é aceito
- **Dados**: Receitas pré-carregadas + novas receitas ficam apenas em memória
- **Imagens**: Placeholders com ícones
- **Favoritos**: Funcionalidade visual apenas

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework de desenvolvimento
- **Google Fonts**: Tipografia (Poppins)
- **Material 3**: Design system base
- **ChangeNotifier**: Gerenciamento de estado
- **Navigator 2.0**: Roteamento e navegação

## 📋 Próximos Passos (não implementados)

- [ ] Integração com API real
- [ ] Autenticação real
- [ ] Persistência de dados local (SQLite/Hive)
- [ ] Upload de imagens
- [ ] Favoritos persistentes
- [ ] Compartilhamento de receitas
- [ ] Modo escuro

---

**Desenvolvido como template funcional - Fase 1 concluída com sucesso! ✨**