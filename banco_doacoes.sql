--  Disciplina : Projeto Integrador de Tecnologia da Informação II
--  Módulo     : 3 — Desenvolvimento da Ação de Extensão
--  Autor      : Miguel Xavier de Brito — UFMS Digital (2026.1)
--  Repositório: https://github.com/omiguelxavier/Projeto-II


-- 1.0 Criação e seleção do banco
CREATE DATABASE IF NOT EXISTS doacoes_comunitarias
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE doacoes_comunitarias;

SET FOREIGN_KEY_CHECKS = 0;  -- Desabilita FK durante carga inicial

CREATE TABLE IF NOT EXISTS categorias (
    id        INT          NOT NULL AUTO_INCREMENT,
    nome      VARCHAR(100) NOT NULL,
    descricao TEXT,
    criado_em DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_categorias        PRIMARY KEY (id),
    CONSTRAINT uq_categoria_nome    UNIQUE (nome)
);


CREATE TABLE IF NOT EXISTS usuarios (
    id         INT          NOT NULL AUTO_INCREMENT,
    nome       VARCHAR(150) NOT NULL,
    email      VARCHAR(150) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL COMMENT 'Hash SHA-256 da senha',
    perfil     ENUM('admin','voluntario','visualizador')
                            NOT NULL DEFAULT 'voluntario',
    ativo      TINYINT(1)   NOT NULL DEFAULT 1,
    criado_em  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuarios          PRIMARY KEY (id),
    CONSTRAINT uq_usuario_email     UNIQUE (email)
);


CREATE TABLE IF NOT EXISTS doadores (
    id        INT          NOT NULL AUTO_INCREMENT,
    nome      VARCHAR(150) NOT NULL,
    cpf       VARCHAR(14),
    telefone  VARCHAR(20),
    email     VARCHAR(150),
    endereco  VARCHAR(255),
    criado_em DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_doadores          PRIMARY KEY (id),
    CONSTRAINT uq_doador_cpf        UNIQUE (cpf)
);


CREATE TABLE IF NOT EXISTS beneficiarios (
    id                  INT          NOT NULL AUTO_INCREMENT,
    nome                VARCHAR(150) NOT NULL,
    cpf                 VARCHAR(14),
    telefone            VARCHAR(20),
    endereco            VARCHAR(255),
    num_membros_familia INT          NOT NULL DEFAULT 1
                        CHECK (num_membros_familia >= 1),
    criado_em           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_beneficiarios     PRIMARY KEY (id),
    CONSTRAINT uq_beneficiario_cpf  UNIQUE (cpf)
);


CREATE TABLE IF NOT EXISTS itens (
    id                 INT          NOT NULL AUTO_INCREMENT,
    nome               VARCHAR(150) NOT NULL,
    id_categoria       INT          NOT NULL,
    descricao          TEXT,
    unidade            VARCHAR(50)  NOT NULL DEFAULT 'unidade',
    quantidade_estoque INT          NOT NULL DEFAULT 0
                       CHECK (quantidade_estoque >= 0),
    atualizado_em      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
                       ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_itens             PRIMARY KEY (id),
    CONSTRAINT fk_item_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS doacoes (
    id            INT  NOT NULL AUTO_INCREMENT,
    id_doador     INT  NOT NULL,
    id_item       INT  NOT NULL,
    quantidade    INT  NOT NULL CHECK (quantidade > 0),
    data_doacao   DATE NOT NULL,
    observacoes   TEXT,
    id_usuario    INT,
    registrado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_doacoes           PRIMARY KEY (id),
    CONSTRAINT fk_doacao_doador
        FOREIGN KEY (id_doador)  REFERENCES doadores(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_doacao_item
        FOREIGN KEY (id_item)    REFERENCES itens(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_doacao_usuario
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
        ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS distribuicoes (
    id                INT  NOT NULL AUTO_INCREMENT,
    id_beneficiario   INT  NOT NULL,
    id_item           INT  NOT NULL,
    quantidade        INT  NOT NULL CHECK (quantidade > 0),
    data_distribuicao DATE NOT NULL,
    observacoes       TEXT,
    id_usuario        INT,
    registrado_em     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_distribuicoes     PRIMARY KEY (id),
    CONSTRAINT fk_dist_beneficiario
        FOREIGN KEY (id_beneficiario) REFERENCES beneficiarios(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_dist_item
        FOREIGN KEY (id_item)         REFERENCES itens(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_dist_usuario
        FOREIGN KEY (id_usuario)      REFERENCES usuarios(id)
        ON DELETE SET NULL ON UPDATE CASCADE
);


CREATE INDEX idx_doacoes_data         ON doacoes(data_doacao);
CREATE INDEX idx_doacoes_doador       ON doacoes(id_doador);
CREATE INDEX idx_distribuicoes_data   ON distribuicoes(data_distribuicao);
CREATE INDEX idx_distribuicoes_benef  ON distribuicoes(id_beneficiario);
CREATE INDEX idx_itens_categoria      ON itens(id_categoria);




DELIMITER $$

-- Trigger 2.1: Após nova doação → incrementa estoque do item
CREATE TRIGGER trg_entrada_estoque
AFTER INSERT ON doacoes
FOR EACH ROW
BEGIN
    UPDATE itens
       SET quantidade_estoque = quantidade_estoque + NEW.quantidade
     WHERE id = NEW.id_item;
END$$

-- Trigger 2.2: Após nova distribuição → decrementa estoque do item
CREATE TRIGGER trg_saida_estoque
AFTER INSERT ON distribuicoes
FOR EACH ROW
BEGIN
    UPDATE itens
       SET quantidade_estoque = quantidade_estoque - NEW.quantidade
     WHERE id = NEW.id_item;
END$$

DELIMITER ;

SET FOREIGN_KEY_CHECKS = 1;




-- 3.1 Categorias de itens
INSERT INTO categorias (nome, descricao) VALUES
  ('Alimento',                'Generos alimenticios nao pereciveis e pereciveis'),
  ('Roupa',                   'Vestuario adulto e infantil'),
  ('Calcado',                 'Sapatos, sandalias, tenis e botas'),
  ('Brinquedo',               'Brinquedos e jogos infantis'),
  ('Medicamento',             'Medicamentos com receita medica ou OTC'),
  ('Produto de Higiene',      'Sabonete, shampoo, pasta de dente, absorventes etc.'),
  ('Movel / Eletrodomestico', 'Mesas, cadeiras, geladeiras, fogoes etc.'),
  ('Material Escolar',        'Cadernos, lapis, canetas, mochilas etc.');

-- 3.2 Usuários do sistema
INSERT INTO usuarios (nome, email, senha_hash, perfil) VALUES
  ('Admin Goiania',    'admin@doacoesgoiania.org',    SHA2('Admin@2026!',  256), 'admin'),
  ('Maria Voluntaria', 'maria.voluntaria@gmail.com',  SHA2('Maria@2026!',  256), 'voluntario'),
  ('Joao Voluntario',  'joao.voluntario@gmail.com',   SHA2('Joao@2026!',   256), 'voluntario'),
  ('Ana Supervisora',  'ana.supervisora@doacoes.org', SHA2('Ana@2026!',    256), 'admin');

-- 3.3 Doadores
INSERT INTO doadores (nome, cpf, telefone, email, endereco) VALUES
  ('Carlos Ferreira',       '123.456.789-00', '(62) 99100-1111', 'carlos@email.com',         'Rua das Flores, 10 - Goiania/GO'),
  ('Fernanda Lima',         '234.567.890-11', '(62) 99200-2222', 'fernanda@email.com',        'Av. Brasil, 250 - Goiania/GO'),
  ('Roberto Souza',         '345.678.901-22', '(62) 99300-3333', 'roberto@email.com',         'Rua XV de Novembro, 85 - Goiania/GO'),
  ('Supermercado BomPreco', '00.111.222/0001-33', '(62) 3100-0001', 'contato@bompreco.com',   'Av. Anhanguera, 1500 - Goiania/GO'),
  ('Igreja Batista Central','00.222.333/0001-44', '(62) 3200-0002', 'contato@igrejabatista.org','Rua 24, 300 - Goiania/GO');

-- 3.4 Beneficiários
INSERT INTO beneficiarios (nome, cpf, telefone, endereco, num_membros_familia) VALUES
  ('Ana Pereira',    '456.789.012-33', '(62) 98100-4444', 'Vila Mutirao - Goiania/GO',          3),
  ('Jose Almeida',   '567.890.123-44', '(62) 98200-5555', 'Bairro Novo Mundo - Goiania/GO',     5),
  ('Luciana Costa',  '678.901.234-55', '(62) 98300-6666', 'Setor Pedro Ludovico - Goiania/GO',  2),
  ('Marcos Ribeiro', '789.012.345-66', '(62) 98400-7777', 'Bairro Jardim America - Goiania/GO', 4),
  ('Patricia Gomes', '890.123.456-77', '(62) 98500-8888', 'Vila Santa Isabel - Goiania/GO',     6);

-- 3.5 Itens em estoque (saldo inicial = 0, triggers atualizarão via doacoes)
INSERT INTO itens (nome, id_categoria, descricao, unidade) VALUES
  ('Arroz 5kg',           1, 'Pacote de arroz branco polido 5 kg',         'pacote'),
  ('Feijao Carioca 1kg',  1, 'Pacote de feijao carioca 1 kg',              'pacote'),
  ('Oleo de Soja 900ml',  1, 'Frasco de oleo de soja refinado 900 ml',     'frasco'),
  ('Camiseta Adulto',     2, 'Camiseta de malha - tamanhos P/M/G/GG',      'peca'),
  ('Calca Jeans Adulto',  2, 'Calca jeans adulto - varios tamanhos',       'peca'),
  ('Tenis Infantil',      3, 'Tenis infantil - varios numeros',             'par'),
  ('Sandalia Adulto',     3, 'Sandalia adulto feminino/masculino',          'par'),
  ('Boneca de Plastico',  4, 'Boneca infantil de plastico rigido',          'unidade'),
  ('Sabonete 90g',        6, 'Sabonete em barra 90 g',                     'unidade'),
  ('Caderno 96 Folhas',   8, 'Caderno universitario 96 folhas capa dura',  'unidade');

-- 3.6 Doações recebidas — triggers incrementarão quantidade_estoque automaticamente
INSERT INTO doacoes (id_doador, id_item, quantidade, data_doacao, observacoes, id_usuario) VALUES
  (4,  1, 50, '2026-04-05', 'Doacao mensal - Supermercado BomPreco',      1),
  (4,  2, 30, '2026-04-05', 'Doacao mensal - Supermercado BomPreco',      1),
  (4,  3, 20, '2026-04-05', 'Doacao mensal - Supermercado BomPreco',      1),
  (5,  4, 40, '2026-04-10', 'Campanha de roupas - Igreja Batista Central', 2),
  (5,  5, 25, '2026-04-10', 'Campanha de roupas - Igreja Batista Central', 2),
  (1,  6, 15, '2026-04-15', NULL,                                           2),
  (2,  9, 60, '2026-04-20', 'Kit higiene - Fernanda Lima',                 3),
  (3, 10, 30, '2026-05-02', 'Material escolar - Roberto Souza',            1),
  (1,  1, 20, '2026-05-10', NULL,                                           2),
  (5,  8, 12, '2026-05-15', 'Brinquedos em bom estado - Igreja Batista',   3);

-- 3.7 Distribuições realizadas — triggers decrementarão quantidade_estoque automaticamente
INSERT INTO distribuicoes (id_beneficiario, id_item, quantidade, data_distribuicao, observacoes, id_usuario) VALUES
  (1,  1, 2, '2026-04-08', 'Cesta basica - familia Pereira',       2),
  (1,  2, 1, '2026-04-08', 'Cesta basica - familia Pereira',       2),
  (2,  1, 3, '2026-04-08', 'Cesta basica - familia Almeida',       2),
  (2,  2, 2, '2026-04-08', 'Cesta basica - familia Almeida',       2),
  (3,  4, 2, '2026-04-12', 'Distribuicao de roupas - familia Costa',   3),
  (4,  4, 3, '2026-04-12', 'Distribuicao de roupas - familia Ribeiro', 3),
  (5,  9, 4, '2026-04-22', 'Kit higiene - familia Gomes',          2),
  (1, 10, 2, '2026-05-05', 'Material escolar - familia Pereira',   3),
  (3,  6, 1, '2026-05-08', 'Calcado infantil - familia Costa',     2),
  (5,  1, 2, '2026-05-12', 'Cesta basica - familia Gomes',        3);




-- Consulta 4.1: Estoque atual consolidado por categoria
SELECT
    i.id,
    i.nome                   AS item,
    c.nome                   AS categoria,
    i.quantidade_estoque     AS saldo,
    i.unidade,
    i.atualizado_em
FROM itens i
JOIN categorias c ON i.id_categoria = c.id
ORDER BY c.nome, i.nome;

-- Consulta 4.2: Ranking de doadores por volume total doado
SELECT
    d.nome                       AS doador,
    COUNT(do.id)                 AS total_transacoes,
    SUM(do.quantidade)           AS total_unidades_doadas
FROM doadores d
JOIN doacoes do ON do.id_doador = d.id
GROUP BY d.id, d.nome
ORDER BY total_unidades_doadas DESC;

-- Consulta 4.3: Historico completo de doacoes com detalhes
SELECT
    do.id,
    d.nome            AS doador,
    i.nome            AS item,
    c.nome            AS categoria,
    do.quantidade,
    do.data_doacao,
    do.observacoes,
    u.nome            AS registrado_por
FROM doacoes do
JOIN doadores   d ON do.id_doador   = d.id
JOIN itens      i ON do.id_item     = i.id
JOIN categorias c ON i.id_categoria = c.id
LEFT JOIN usuarios u ON do.id_usuario = u.id
ORDER BY do.data_doacao DESC;

-- Consulta 4.4: Distribuicoes do mes corrente por beneficiario
SELECT
    b.nome                   AS beneficiario,
    b.num_membros_familia    AS membros_familia,
    i.nome                   AS item,
    di.quantidade,
    di.data_distribuicao
FROM distribuicoes di
JOIN beneficiarios b ON di.id_beneficiario = b.id
JOIN itens         i ON di.id_item         = i.id
WHERE MONTH(di.data_distribuicao) = MONTH(CURDATE())
  AND YEAR(di.data_distribuicao)  = YEAR(CURDATE())
ORDER BY b.nome, di.data_distribuicao;

-- Consulta 4.5: Relatorio por categoria (entradas vs saidas vs saldo)
SELECT
    c.nome                            AS categoria,
    COALESCE(SUM(do.quantidade), 0)   AS total_recebido,
    COALESCE(SUM(di.quantidade), 0)   AS total_distribuido,
    i.quantidade_estoque              AS saldo_atual
FROM categorias c
LEFT JOIN itens         i  ON i.id_categoria = c.id
LEFT JOIN doacoes       do ON do.id_item      = i.id
LEFT JOIN distribuicoes di ON di.id_item      = i.id
GROUP BY c.id, c.nome, i.quantidade_estoque
ORDER BY c.nome;

-- Consulta 4.6: Alerta de estoque critico (saldo abaixo de 5 unidades)
SELECT
    i.nome                   AS item,
    c.nome                   AS categoria,
    i.quantidade_estoque     AS saldo_atual,
    i.unidade
FROM itens i
JOIN categorias c ON i.id_categoria = c.id
WHERE i.quantidade_estoque < 5
ORDER BY i.quantidade_estoque ASC;



-- 5.1 UPDATE: corrigir quantidade de doacao registrada com erro
UPDATE doacoes
   SET quantidade  = 55,
       observacoes = 'Quantidade corrigida apos conferencia fisica - 2026-05-20'
 WHERE id = 1;

-- 5.2 UPDATE: inativar voluntario desligado da organizacao
UPDATE usuarios
   SET ativo = 0
 WHERE email = 'joao.voluntario@gmail.com';

-- 5.3 UPDATE: atualizar telefone de um doador
UPDATE doadores
   SET telefone = '(62) 99100-9999'
 WHERE cpf = '123.456.789-00';

-- 5.4 DELETE: remover registro de distribuicao lancado em duplicidade
DELETE FROM distribuicoes
 WHERE id = 10
   AND data_distribuicao = '2026-05-12';

-- 5.5 DELETE: remover beneficiario sem historico de atendimentos
DELETE FROM beneficiarios
 WHERE id NOT IN (SELECT DISTINCT id_beneficiario FROM distribuicoes)
   AND id = 5;  -- Filtro de ID para maior seguranca