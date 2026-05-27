Sistema de Gestão de Doações Comunitárias — Doações Goiânia

> Aplicação web para cadastro, listagem e controle de doações recebidas por centros comunitários da região de Goiânia – GO.

---

Sobre o Projeto

O problema identificado foi a ausência de ferramentas digitais acessíveis para o controle de doações em organizações comunitárias, que costumam registrar entradas de itens de forma manual, em cadernos ou planilhas físicas, resultando em perda de dados e falta de transparência.

A aplicação resolve esse problema oferecendo uma interface simples e intuitiva, acessível diretamente no navegador, sem necessidade de instalação ou servidor.



Funcionalidades
Cadastro de doações com nome do doador, tipo de item, descrição, quantidade, data e observações
Listagem de todas as doações em tabela responsiva, ordenadas da mais recente para a mais antiga
Busca em tempo real por nome do doador, descrição ou tipo de item
Filtro por categoria de item (Alimento, Roupa, Calçado, Brinquedo etc.)
Exclusão de registros com confirmação via modal
Painel de resumo com 4 indicadores: total de doações, doadores únicos, itens registrados e doações do mês
Persistência de dados via `localStorage` (os dados não somem ao fechar o navegador)
nterface totalmente responsiva — funciona em desktop, tablet e celular



Como Usar

pré-requisitos
Qualquer navegador moderno: Google Chrome, Firefox, Edge
Conexão com internet

Instalação

Opção 1 — Clonar o repositório:
bash
git clone https://github.com/omiguelxavier/Projeto-II.git
cd Projeto-II

Opção 2 — Download direto:

1. Clique em Code → Download ZIP nesta página
2. Extraia a pasta ZIP no seu computador

executando

1. Abra a pasta do projeto
2. Dê dois cliques no arquivo `index.html`
3. A aplicação abrirá diretamente no seu navegador — pronto!

> Não é necessário instalar nada, rodar servidor local ou configurar banco de dados.

---

Estrutura de Arquivos


Projeto-II/
│
├── index.html       # Estrutura HTML da aplicação (navbar, cards, formulário, tabela)
├── style.css        # Estilização customizada com variáveis CSS e media queries
├── app.js           # Lógica da aplicação (cadastro, filtros, localStorage, DOM)
└── README.md        # Documentação do projeto




Tecnologias Utilizadas

| Tecnologia | Versão | Finalidade |
|---|---|---|
| HTML5 | — | Estrutura semântica da página |
| CSS3 | — | Estilização, variáveis e animações |
| JavaScript | ES6+ | Lógica, DOM e persistência |
| Bootstrap | 5.3.3 | Framework responsivo e componentes UI |
| Bootstrap Icons | 1.11.3 | Ícones vetoriais |
| Google Fonts | — | Tipografia (DM Sans + Playfair Display) |
| localStorage | API nativa | Persistência de dados no navegador |
