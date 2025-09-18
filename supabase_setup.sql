-- Script SQL para configurar as tabelas do projeto Receitas da Vitória no Supabase
-- Execute este script no SQL Editor do Supabase

-- =============================================================================
-- TABELA: usuarios
-- =============================================================================
CREATE TABLE IF NOT EXISTS usuarios (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  nome TEXT,
  avatar_url TEXT,
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: categorias
-- =============================================================================
CREATE TABLE IF NOT EXISTS categorias (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nome TEXT NOT NULL UNIQUE,
  descricao TEXT,
  cor TEXT DEFAULT '#FF6B6B',
  icone TEXT DEFAULT 'restaurant',
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: receitas
-- =============================================================================
CREATE TABLE IF NOT EXISTS receitas (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  titulo TEXT NOT NULL,
  descricao TEXT,
  categoria_id UUID REFERENCES categorias(id) ON DELETE SET NULL,
  tempo_preparo TEXT,
  porcoes INTEGER,
  dificuldade TEXT CHECK (dificuldade IN ('fácil', 'médio', 'difícil')),
  url_imagem TEXT,
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: ingredientes
-- =============================================================================
CREATE TABLE IF NOT EXISTS ingredientes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  receita_id UUID REFERENCES receitas(id) ON DELETE CASCADE NOT NULL,
  nome TEXT NOT NULL,
  quantidade TEXT,
  unidade TEXT,
  ordem INTEGER DEFAULT 0,
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: passos_preparo
-- =============================================================================
CREATE TABLE IF NOT EXISTS passos_preparo (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  receita_id UUID REFERENCES receitas(id) ON DELETE CASCADE NOT NULL,
  passo TEXT NOT NULL,
  ordem INTEGER NOT NULL,
  tempo_estimado TEXT,
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: comentarios
-- =============================================================================
CREATE TABLE IF NOT EXISTS comentarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  receita_id UUID REFERENCES receitas(id) ON DELETE CASCADE NOT NULL,
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  conteudo TEXT NOT NULL,
  avaliacao INTEGER CHECK (avaliacao >= 1 AND avaliacao <= 5),
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: favoritos
-- =============================================================================
CREATE TABLE IF NOT EXISTS favoritos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  receita_id UUID REFERENCES receitas(id) ON DELETE CASCADE NOT NULL,
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(usuario_id, receita_id)
);

-- =============================================================================
-- TABELA: listas_compras
-- =============================================================================
CREATE TABLE IF NOT EXISTS listas_compras (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE NOT NULL,
  nome TEXT NOT NULL,
  descricao TEXT,
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- TABELA: itens_lista_compras
-- =============================================================================
CREATE TABLE IF NOT EXISTS itens_lista_compras (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  lista_id UUID REFERENCES listas_compras(id) ON DELETE CASCADE NOT NULL,
  ingrediente_id UUID REFERENCES ingredientes(id) ON DELETE CASCADE,
  nome_personalizado TEXT,
  quantidade TEXT,
  unidade TEXT,
  concluido BOOLEAN DEFAULT FALSE,
  data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================================================
-- INSERIR DADOS INICIAIS
-- =============================================================================

-- Categorias iniciais
INSERT INTO categorias (nome, descricao, cor, icone) VALUES
('Doces', 'Sobremesas e doces variados', '#FF6B6B', 'cake'),
('Salgados', 'Salgados e petiscos', '#4ECDC4', 'restaurant'),
('Carnes', 'Pratos com carne', '#45B7D1', 'restaurant_menu'),
('Massas', 'Massas e molhos', '#F9CA24', 'restaurant'),
('Bebidas', 'Bebidas e sucos', '#A8E6CF', 'local_drink'),
('Vegetarianas', 'Pratos vegetarianos', '#DDA0DD', 'eco'),
('Veganas', 'Pratos veganos', '#98FB98', 'spa')
ON CONFLICT (nome) DO NOTHING;

-- =============================================================================
-- ÍNDICES PARA PERFORMANCE
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_receitas_usuario_id ON receitas(usuario_id);
CREATE INDEX IF NOT EXISTS idx_receitas_categoria_id ON receitas(categoria_id);
CREATE INDEX IF NOT EXISTS idx_ingredientes_receita_id ON ingredientes(receita_id);
CREATE INDEX IF NOT EXISTS idx_passos_preparo_receita_id ON passos_preparo(receita_id);
CREATE INDEX IF NOT EXISTS idx_comentarios_receita_id ON comentarios(receita_id);
CREATE INDEX IF NOT EXISTS idx_comentarios_usuario_id ON comentarios(usuario_id);
CREATE INDEX IF NOT EXISTS idx_favoritos_usuario_id ON favoritos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_favoritos_receita_id ON favoritos(receita_id);
CREATE INDEX IF NOT EXISTS idx_listas_compras_usuario_id ON listas_compras(usuario_id);
CREATE INDEX IF NOT EXISTS idx_itens_lista_lista_id ON itens_lista_compras(lista_id);

-- =============================================================================
-- REGRAS DE SEGURANÇA (RLS - Row Level Security)
-- =============================================================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE receitas ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE passos_preparo ENABLE ROW LEVEL SECURITY;
ALTER TABLE comentarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE favoritos ENABLE ROW LEVEL SECURITY;
ALTER TABLE listas_compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE itens_lista_compras ENABLE ROW LEVEL SECURITY;

-- Políticas para usuarios
CREATE POLICY "Users can view their own profile" ON usuarios
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON usuarios
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON usuarios
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Políticas para categorias (públicas para leitura)
CREATE POLICY "Anyone can view categories" ON categorias
  FOR SELECT USING (true);

-- Políticas para receitas
CREATE POLICY "Users can view all recipes" ON receitas
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own recipes" ON receitas
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Users can update their own recipes" ON receitas
  FOR UPDATE USING (auth.uid() = usuario_id);

CREATE POLICY "Users can delete their own recipes" ON receitas
  FOR DELETE USING (auth.uid() = usuario_id);

-- Políticas para ingredientes
CREATE POLICY "Users can view ingredients of visible recipes" ON ingredientes
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM receitas
      WHERE receitas.id = ingredientes.receita_id
    )
  );

CREATE POLICY "Users can insert ingredients for their recipes" ON ingredientes
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM receitas
      WHERE receitas.id = ingredientes.receita_id
      AND receitas.usuario_id = auth.uid()
    )
  );

CREATE POLICY "Users can update ingredients of their recipes" ON ingredientes
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM receitas
      WHERE receitas.id = ingredientes.receita_id
      AND receitas.usuario_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete ingredients of their recipes" ON ingredientes
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM receitas
      WHERE receitas.id = ingredientes.receita_id
      AND receitas.usuario_id = auth.uid()
    )
  );

-- Políticas para passos_preparo (mesmas regras dos ingredientes)
CREATE POLICY "Users can view steps of visible recipes" ON passos_preparo
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM receitas
      WHERE receitas.id = passos_preparo.receita_id
    )
  );

CREATE POLICY "Users can insert steps for their recipes" ON passos_preparo
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM receitas
      WHERE receitas.id = passos_preparo.receita_id
      AND receitas.usuario_id = auth.uid()
    )
  );

CREATE POLICY "Users can update steps of their recipes" ON passos_preparo
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM receitas
      WHERE receitas.id = passos_preparo.receita_id
      AND receitas.usuario_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete steps of their recipes" ON passos_preparo
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM receitas
      WHERE receitas.id = passos_preparo.receita_id
      AND receitas.usuario_id = auth.uid()
    )
  );

-- Políticas para comentarios
CREATE POLICY "Users can view all comments" ON comentarios
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own comments" ON comentarios
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Users can update their own comments" ON comentarios
  FOR UPDATE USING (auth.uid() = usuario_id);

CREATE POLICY "Users can delete their own comments" ON comentarios
  FOR DELETE USING (auth.uid() = usuario_id);

-- Políticas para favoritos
CREATE POLICY "Users can view their own favorites" ON favoritos
  FOR SELECT USING (auth.uid() = usuario_id);

CREATE POLICY "Users can insert their own favorites" ON favoritos
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Users can delete their own favorites" ON favoritos
  FOR DELETE USING (auth.uid() = usuario_id);

-- Políticas para listas_compras
CREATE POLICY "Users can view their own shopping lists" ON listas_compras
  FOR SELECT USING (auth.uid() = usuario_id);

CREATE POLICY "Users can insert their own shopping lists" ON listas_compras
  FOR INSERT WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Users can update their own shopping lists" ON listas_compras
  FOR UPDATE USING (auth.uid() = usuario_id);

CREATE POLICY "Users can delete their own shopping lists" ON listas_compras
  FOR DELETE USING (auth.uid() = usuario_id);

-- Políticas para itens_lista_compras
CREATE POLICY "Users can view items from their shopping lists" ON itens_lista_compras
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM listas_compras
      WHERE listas_compras.id = itens_lista_compras.lista_id
      AND listas_compras.usuario_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert items to their shopping lists" ON itens_lista_compras
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM listas_compras
      WHERE listas_compras.id = itens_lista_compras.lista_id
      AND listas_compras.usuario_id = auth.uid()
    )
  );

CREATE POLICY "Users can update items from their shopping lists" ON itens_lista_compras
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM listas_compras
      WHERE listas_compras.id = itens_lista_compras.lista_id
      AND listas_compras.usuario_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete items from their shopping lists" ON itens_lista_compras
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM listas_compras
      WHERE listas_compras.id = itens_lista_compras.lista_id
      AND listas_compras.usuario_id = auth.uid()
    )
  );

-- =============================================================================
-- FUNCTIONS ÚTEIS
-- =============================================================================

-- Function para atualizar data_atualizacao automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.data_atualizacao = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar data_atualizacao
CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON usuarios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_receitas_updated_at BEFORE UPDATE ON receitas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comentarios_updated_at BEFORE UPDATE ON comentarios
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_listas_compras_updated_at BEFORE UPDATE ON listas_compras
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
