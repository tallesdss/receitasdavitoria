# 📌 PRD – Projeto Flutter (Fase 1: Configuração + Frontend Template)

## 🎯 Objetivo
Criar um **template funcional em Flutter**, **somente frontend**, com **design system padronizado** e **navegação completa**, utilizando **LocalState/PageState** como banco temporário.

---

## 📂 Estrutura do Projeto

- [x] Criar projeto Flutter do zero
- [x] Configurar Design System
  - [x] Tipografia (ex.: Poppins ou similar)
  - [x] Paleta de cores padronizada
  - [x] Estilos globais de botões, inputs, títulos e textos

---

## 🖼️ Telas & Navegação

- [x] Tela de Login
  - [x] Campos fake (sem lógica real de autenticação)
  - [x] Botão leva para tela inicial

- [x] Tela de Cadastro
  - [x] Campos fake de cadastro
  - [x] Botão leva para tela inicial

- [x] Tela Inicial (Home)
  - [x] Exibir lista fake de receitas (armazenadas em LocalState/PageState)
  - [x] Botão/ação para ver detalhe da receita

- [x] Tela de Detalhe da Receita
  - [x] Mostrar receita fake carregada do LocalState
  - [x] Layout pronto para imagem, título, descrição e ingredientes

- [x] Tela de Criar Receita
  - [x] Inputs para criar receita fake
  - [x] Salvar no LocalState/PageState

---

## 🔄 Navegação

- [x] Toda a navegação deve estar funcionando (mesmo sem backend)
- [x] Fluxo básico: Login → Home → Ver Receita → Criar Receita
- [x] Navegação entre todas as telas obrigatória

---

## 🗄️ Armazenamento Temporário

- [x] Usar LocalState ou PageState para armazenar dados fake
- [x] Garantir que receitas criadas sejam visíveis na Home enquanto app roda
- [x] Estrutura preparada para futura substituição pelo backend

---

## 🚫 O que NÃO deve ser feito

- [x] Nenhuma lógica de autenticação real
- [x] Nenhuma integração de API
- [x] Nenhum backend
- [x] Nenhum recurso de produção (tudo é mock/fake)
