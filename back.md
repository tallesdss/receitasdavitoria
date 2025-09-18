# ⚙️ PRD – Configuração e Implementação do Projeto com Supabase  

## 🎯 Objetivo  
Migrar o projeto Flutter (atualmente baseado em AppState com dados fictícios) para utilizar o **Supabase** como back-end real.  
O escopo inclui: **configuração inicial**, **autenticação**, **criação de tabelas**, **integração e testes completos**.  
Todo o processo deve ser feito **em etapas sequenciais**, para garantir que cada fase esteja validada antes de avançar.  

**Observação inicial:**  
O projeto já foi criado no **MCP Supabase** e já possuímos:  
- **URL do projeto**  
- **Chave anônima**  

Portanto, **não será criado um novo projeto**, apenas configurado e integrado ao Flutter.  

---

## 🛠️ Etapa 1 – Configuração Inicial
- [x] Instalar dependências do **Supabase Flutter**.
- [x] Configurar o Supabase no projeto utilizando a **URL** e a **chave anônima**.
- [x] Testar a conexão inicial com o Supabase.
- [x] Confirmar ambiente funcionando antes de prosseguir. ✅  

---

## 🔑 Etapa 2 – Sistema de Autenticação
- [x] Implementar **criação de conta, login e alteração de senha** via e-mail/senha.
- [x] No cadastro:
  - [x] Armazenar e-mail e senha no serviço de autenticação do Supabase.
  - [x] Criar registro correspondente na tabela **usuários** (com ID, e-mail e outros campos necessários).
- [x] Testar fluxos:
  - [x] Criar conta
  - [x] Login
  - [x] Alteração de senha
- [x] Validar que o fluxo funciona antes de avançar. ✅  

---

## 🗄️ Etapa 3 – Estrutura de Tabelas
- [x] Criar a tabela **usuários** com todos os campos necessários.
- [x] Mapear todas as tabelas adicionais necessárias para o app (ex.: receitas, ingredientes, favoritos, etc.).
- [x] Remover todas as variáveis/dados fictícios do projeto (AppState/PageState).
- [x] Definir **relacionamentos** entre tabelas (ex.: usuário → receitas, receita → ingredientes).
- [x] Configurar **regras de permissão (RLS)** para garantir quem pode criar, editar e visualizar cada dado.
- [x] Testar cada tabela individualmente antes da integração final. ✅  

---

## 🔄 Etapa 4 – Integração e Testes
- [x] Integrar tabelas ao sistema de autenticação.
- [x] Testar fluxos completos do app:
  - [x] Criação de usuário
  - [x] Login
  - [x] Alteração de senha
  - [x] Criação e listagem de receitas (dados reais)
  - [x] Consulta/edição apenas dos dados permitidos
- [x] Verificar ausência de dados fictícios.
- [x] Validar que todos os relacionamentos funcionam corretamente. ✅  

---

## 📌 Observações Importantes  
- ⚠️ **Não avançar de etapa sem testar a anterior.**  
- ✅ Todas as tabelas e campos devem estar em **português**.  
- 🔐 Todas as regras de acesso e relacionamentos devem estar claros e testados.  
- 🗑️ Remover **todo dado fictício** (mock/AppState) do app – apenas dados reais via Supabase.  
