-- =============================================================================
-- ATIVIDADE: Criação das Tabelas para o Projeto de Jogo de RPG Online
-- DISCIPLINA: Banco de Dados / Modelagem e DDL
-- SGBD: Microsoft SQL Server (T-SQL)
-- =============================================================================
-- Descrição:
-- Script DDL (Data Definition Language) para criação do banco de dados e das
-- tabelas do jogo de RPG online, conforme o Modelo Entidade-Relacionamento (MER)
-- e o Diagrama Lógico fornecido.
--
-- Entidades contempladas:
-- 1. USUARIOS             (Armazena contas de usuários/jogadores)
-- 2. CLASSES              (Classes dos personagens, ex: Guerreiro, Mago)
-- 3. HABILIDADES          (Habilidades disponíveis no jogo, ex: Bola de Fogo)
-- 4. PERSONAGENS          (Personagens criados pelos usuários, associados a uma classe)
-- 5. CLASSES_HABILIDADES  (Tabela associativa que resolve o relacionamento N:N entre Classes e Habilidades)
-- =============================================================================

-- =============================================================================
-- PARTE 1: CRIAÇÃO E SELEÇÃO DO BANCO DE DADOS
-- =============================================================================

-- Cria o banco de dados caso não exista
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'RPG_DB')
BEGIN
    CREATE DATABASE RPG_DB;
    PRINT 'Banco de dados RPG_DB criado com sucesso!';
END
GO

-- Seleciona o banco de dados para execução dos comandos seguintes
USE RPG_DB;
GO

-- =============================================================================
-- PARTE 2: LIMPEZA PREVENTIVA (DROP TABLE EM ORDEM INVERSA DE DEPENDÊNCIA)
-- =============================================================================
-- Para evitar erros caso o script seja executado mais de uma vez,
-- removemos as tabelas filhas (com FK) antes das tabelas pais (sem FK).

IF OBJECT_ID('dbo.CLASSES_HABILIDADES', 'U') IS NOT NULL DROP TABLE dbo.CLASSES_HABILIDADES;
IF OBJECT_ID('dbo.PERSONAGENS', 'U') IS NOT NULL DROP TABLE dbo.PERSONAGENS;
IF OBJECT_ID('dbo.HABILIDADES', 'U') IS NOT NULL DROP TABLE dbo.HABILIDADES;
IF OBJECT_ID('dbo.CLASSES', 'U') IS NOT NULL DROP TABLE dbo.CLASSES;
IF OBJECT_ID('dbo.USUARIOS', 'U') IS NOT NULL DROP TABLE dbo.USUARIOS;
GO

-- =============================================================================
-- PARTE 3: CRIAÇÃO DAS TABELAS INDEPENDENTES (SEM CHAVES ESTRANGEIRAS)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tabela: USUARIOS
-- Descrição: Guarda as credenciais de login e dados de cada usuário cadastrado.
-- Relacionamento: 1 USUARIO possui N PERSONAGENS (1:N)
-- -----------------------------------------------------------------------------
CREATE TABLE USUARIOS
(
    UsuarioId INT PRIMARY KEY IDENTITY(1,1),
    Email VARCHAR(150) NOT NULL UNIQUE,
    Senha VARCHAR(255) NOT NULL
);
GO

-- -----------------------------------------------------------------------------
-- Tabela: CLASSES
-- Descrição: Registra as classes de personagens (ex.: Guerreiro, Mago, Arqueiro).
-- Relacionamento: 1 CLASSE pertence a N PERSONAGENS (1:N)
--                 N CLASSES possuem N HABILIDADES (N:N, resolvida em CLASSES_HABILIDADES)
-- -----------------------------------------------------------------------------
CREATE TABLE CLASSES
(
    ClasseId INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL UNIQUE,
    Descricao VARCHAR(255) NULL
);
GO

-- -----------------------------------------------------------------------------
-- Tabela: HABILIDADES
-- Descrição: Catálogo de habilidades e magias do jogo.
-- Relacionamento: N HABILIDADES associadas a N CLASSES (N:N, resolvida em CLASSES_HABILIDADES)
-- -----------------------------------------------------------------------------
CREATE TABLE HABILIDADES
(
    HabilidadeId INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(100) NOT NULL UNIQUE
);
GO

-- =============================================================================
-- PARTE 4: CRIAÇÃO DAS TABELAS DEPENDENTES (COM CHAVES ESTRANGEIRAS)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Tabela: PERSONAGENS
-- Descrição: Personagens criados no jogo. Cada personagem pertence a um usuário
--            e possui uma classe selecionada.
-- Chaves Estrangeiras (FK):
--   - UsuarioId -> referencia a tabela USUARIOS(UsuarioId)
--   - ClasseId  -> referencia a tabela CLASSES(ClasseId)
-- -----------------------------------------------------------------------------
CREATE TABLE PERSONAGENS
(
    PersonagemId INT PRIMARY KEY IDENTITY(1,1),
    NomePersonagem VARCHAR(100) NOT NULL,
    UsuarioId INT NOT NULL,
    ClasseId INT NOT NULL,
    
    -- Restrições de Chave Estrangeira (Integridade Referencial)
    CONSTRAINT FK_PERSONAGENS_USUARIOS FOREIGN KEY (UsuarioId) 
        REFERENCES USUARIOS(UsuarioId),
    CONSTRAINT FK_PERSONAGENS_CLASSES FOREIGN KEY (ClasseId) 
        REFERENCES CLASSES(ClasseId)
);
GO

-- -----------------------------------------------------------------------------
-- Tabela: CLASSES_HABILIDADES
-- Descrição: Tabela associativa que resolve o relacionamento Muitos-para-Muitos (N:N)
--            entre CLASSES e HABILIDADES. Uma classe pode ter várias habilidades,
--            e uma mesma habilidade pode pertencer a mais de uma classe.
-- Chaves:
--   - Chave Primária Composta: (ClasseId, HabilidadeId)
--   - FK ClasseId -> referencia CLASSES(ClasseId)
--   - FK HabilidadeId -> referencia HABILIDADES(HabilidadeId)
-- -----------------------------------------------------------------------------
CREATE TABLE CLASSES_HABILIDADES
(
    ClasseId INT NOT NULL,
    HabilidadeId INT NOT NULL,
    
    -- Chave Primária Composta (garante que uma classe não tenha a mesma habilidade repetida)
    CONSTRAINT PK_CLASSES_HABILIDADES PRIMARY KEY (ClasseId, HabilidadeId),
    
    -- Restrições de Chaves Estrangeiras
    CONSTRAINT FK_CLASSES_HABILIDADES_CLASSES FOREIGN KEY (ClasseId) 
        REFERENCES CLASSES(ClasseId),
    CONSTRAINT FK_CLASSES_HABILIDADES_HABILIDADES FOREIGN KEY (HabilidadeId) 
        REFERENCES HABILIDADES(HabilidadeId)
);
GO

-- =============================================================================
-- PARTE 5: DADOS DE TESTE (INSERTS) - COMPROVAÇÃO DE FUNCIONAMENTO
-- =============================================================================
-- Inserindo Usuários
INSERT INTO USUARIOS (Email, Senha) VALUES
('jogador1@rpg.com', 'hash_senha_123'),
('jogador2@rpg.com', 'hash_senha_456'),
('mestre@rpg.com', 'hash_senha_789');

-- Inserindo Classes
INSERT INTO CLASSES (Nome, Descricao) VALUES
('Guerreiro', 'Especialista em combate corpo a corpo e alta defesa com armaduras pesadas.'),
('Mago', 'Conjurador de feitiços arcanos com alto poder de dano mágico em área.'),
('Ladino', 'Ágil e furtivo, especialista em ataques críticos rápidos e armadilhas.'),
('Clérigo', 'Guerreiro sagrado focado em cura, bênçãos divinas e suporte.');

-- Inserindo Habilidades
INSERT INTO HABILIDADES (Nome) VALUES
('Golpe de Espada Pesada'),
('Investida com Escudo'),
('Bola de Fogo'),
('Raio de Gelo'),
('Ataque Furtivo'),
('Esquiva Rápida'),
('Cura Divina'),
('Purificação');

-- Associando Habilidades às Classes (CLASSES_HABILIDADES - N:N)
-- Guerreiro (1) -> Golpe de Espada Pesada (1), Investida com Escudo (2)
INSERT INTO CLASSES_HABILIDADES (ClasseId, HabilidadeId) VALUES (1, 1), (1, 2);

-- Mago (2) -> Bola de Fogo (3), Raio de Gelo (4)
INSERT INTO CLASSES_HABILIDADES (ClasseId, HabilidadeId) VALUES (2, 3), (2, 4);

-- Ladino (3) -> Ataque Furtivo (5), Esquiva Rápida (6)
INSERT INTO CLASSES_HABILIDADES (ClasseId, HabilidadeId) VALUES (3, 5), (3, 6);

-- Clérigo (4) -> Cura Divina (7), Purificação (8), Investida com Escudo (2)
INSERT INTO CLASSES_HABILIDADES (ClasseId, HabilidadeId) VALUES (4, 7), (4, 8), (4, 2);

-- Inserindo Personagens vinculados aos Usuários e Classes
INSERT INTO PERSONAGENS (NomePersonagem, UsuarioId, ClasseId) VALUES
('Thorin Martelo de Ferro', 1, 1),   -- Usuário 1 criando Guerreiro
('Gandalf Cinzento', 1, 2),          -- Usuário 1 criando Mago
('Shadow Walker', 2, 3),             -- Usuário 2 criando Ladino
('Irmão Francis', 3, 4);             -- Usuário 3 criando Clérigo
GO

-- =============================================================================
-- PARTE 6: CONSULTAS DE CONFERÊNCIA (SELECTS COM JOINS)
-- =============================================================================

-- 1. Listar personagens com seus respectivos donos (Usuários) e Classes
SELECT 
    P.PersonagemId,
    P.NomePersonagem,
    U.Email AS DonoDoPersonagem,
    C.Nome AS Classe,
    C.Descricao AS DescricaoDaClasse
FROM PERSONAGENS P
INNER JOIN USUARIOS U ON P.UsuarioId = U.UsuarioId
INNER JOIN CLASSES C ON P.ClasseId = C.ClasseId;

-- 2. Listar as Classes e todas as Habilidades a elas vinculadas (N:N)
SELECT 
    C.Nome AS Classe,
    H.Nome AS Habilidade
FROM CLASSES C
INNER JOIN CLASSES_HABILIDADES CH ON C.ClasseId = CH.ClasseId
INNER JOIN HABILIDADES H ON CH.HabilidadeId = H.HabilidadeId
ORDER BY C.Nome, H.Nome;
GO

