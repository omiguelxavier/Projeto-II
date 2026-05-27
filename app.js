// ---- CHAVE DO localStorage ----
const STORAGE_KEY = 'doacoes_comunitarias';

// ---- ESTADO GLOBAL ----
let doacoes = [];
let idParaExcluir = null;

// ---- INICIALIZAÇÃO ----
document.addEventListener('DOMContentLoaded', () => {
  carregarDoLocalStorage();
  renderizarTabela();
  atualizarCards();
  exibirData();
  definirDataHoje();
});

// ---- EXIBIR DATA ATUAL NA NAVBAR ----
function exibirData() {
  const el = document.getElementById('currentDate');
  const agora = new Date();
  el.textContent = agora.toLocaleDateString('pt-BR', {
    weekday: 'long', day: '2-digit', month: 'long', year: 'numeric'
  });
}

// ---- DEFINIR DATA DE HOJE COMO PADRÃO NO INPUT ----
function definirDataHoje() {
  const hoje = new Date().toISOString().split('T')[0];
  document.getElementById('dataDoacao').value = hoje;
}

// ---- CARREGAR DO localStorage ----
function carregarDoLocalStorage() {
  const dados = localStorage.getItem(STORAGE_KEY);
  doacoes = dados ? JSON.parse(dados) : [];
}

// ---- SALVAR NO localStorage ----
function salvarNoLocalStorage() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(doacoes));
}

// ---- CADASTRAR DOAÇÃO ----
function cadastrarDoacao() {
  const nomeDoador   = document.getElementById('nomeDoador').value.trim();
  const tipoItem     = document.getElementById('tipoItem').value;
  const descricaoItem = document.getElementById('descricaoItem').value.trim();
  const quantidade   = parseInt(document.getElementById('quantidade').value);
  const dataDoacao   = document.getElementById('dataDoacao').value;
  const observacoes  = document.getElementById('observacoes').value.trim();

  // Validação
  if (!nomeDoador || !tipoItem || !descricaoItem || !quantidade || !dataDoacao) {
    mostrarToast('Preencha todos os campos obrigatórios (*).', 'warning');
    return;
  }

  if (quantidade < 1) {
    mostrarToast('A quantidade deve ser pelo menos 1.', 'warning');
    return;
  }

  const novaDoacao = {
    id: Date.now(),
    nomeDoador,
    tipoItem,
    descricaoItem,
    quantidade,
    dataDoacao,
    observacoes,
    criadoEm: new Date().toISOString()
  };

  doacoes.unshift(novaDoacao); // insere no início (mais recente primeiro)
  salvarNoLocalStorage();
  renderizarTabela();
  atualizarCards();
  limparFormulario();
  mostrarToast('Doação cadastrada com sucesso!', 'success');
}

// ---- LIMPAR FORMULÁRIO ----
function limparFormulario() {
  document.getElementById('nomeDoador').value    = '';
  document.getElementById('tipoItem').value      = '';
  document.getElementById('descricaoItem').value = '';
  document.getElementById('quantidade').value    = '';
  document.getElementById('observacoes').value   = '';
  definirDataHoje();
  document.getElementById('nomeDoador').focus();
}

// ---- RENDERIZAR TABELA ----
function renderizarTabela(lista) {
  const dados = lista !== undefined ? lista : doacoes;
  const tbody = document.getElementById('corpoTabela');
  const empty = document.getElementById('emptyState');

  tbody.innerHTML = '';

  if (dados.length === 0) {
    empty.style.display = 'flex';
    return;
  }

  empty.style.display = 'none';

  dados.forEach((d, index) => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td class="text-muted" style="font-size:0.78rem;">${String(index + 1).padStart(2, '0')}</td>
      <td>
        <div style="font-weight:600;font-size:0.88rem;">${escaparHTML(d.nomeDoador)}</div>
      </td>
      <td><span class="badge-tipo ${classBadge(d.tipoItem)}">${escaparHTML(d.tipoItem)}</span></td>
      <td>
        <div style="font-size:0.88rem;">${escaparHTML(d.descricaoItem)}</div>
        ${d.observacoes ? `<div style="font-size:0.75rem;color:#888;">${escaparHTML(d.observacoes)}</div>` : ''}
      </td>
      <td style="font-weight:600;text-align:center;">${d.quantidade}</td>
      <td style="white-space:nowrap;">${formatarData(d.dataDoacao)}</td>
      <td>
        <button class="btn-action btn-action--delete" title="Excluir" onclick="confirmarExclusao(${d.id})">
          <i class="bi bi-trash3-fill"></i>
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

// ---- FILTRAR / BUSCAR ----
function filtrarDoacoes() {
  const busca  = document.getElementById('buscaInput').value.toLowerCase().trim();
  const tipo   = document.getElementById('filtroTipo').value;

  const filtradas = doacoes.filter(d => {
    const matchBusca = !busca ||
      d.nomeDoador.toLowerCase().includes(busca)  ||
      d.descricaoItem.toLowerCase().includes(busca)||
      d.tipoItem.toLowerCase().includes(busca);
    const matchTipo  = !tipo || d.tipoItem === tipo;
    return matchBusca && matchTipo;
  });

  renderizarTabela(filtradas);
}

// ---- CONFIRMAR EXCLUSÃO (Modal) ----
function confirmarExclusao(id) {
  idParaExcluir = id;
  const modal = new bootstrap.Modal(document.getElementById('modalExcluir'));
  modal.show();

  document.getElementById('btnConfirmarExcluir').onclick = () => {
    excluirDoacao(id);
    modal.hide();
  };
}

// ---- EXCLUIR DOAÇÃO ----
function excluirDoacao(id) {
  doacoes = doacoes.filter(d => d.id !== id);
  salvarNoLocalStorage();
  filtrarDoacoes(); // respeita filtros ativos
  atualizarCards();
  mostrarToast('Doação removida.', 'danger');
  idParaExcluir = null;
}

// ---- ATUALIZAR CARDS DE RESUMO ----
function atualizarCards() {
  // Total de doações
  document.getElementById('totalDoacoes').textContent = doacoes.length;

  // Doadores únicos
  const doadores = new Set(doacoes.map(d => d.nomeDoador.toLowerCase()));
  document.getElementById('totalDoadores').textContent = doadores.size;

  // Total de itens (soma das quantidades)
  const totalItens = doacoes.reduce((acc, d) => acc + d.quantidade, 0);
  document.getElementById('totalItens').textContent = totalItens;

  // Doações do mês atual
  const agora = new Date();
  const mesAtual = agora.getMonth();
  const anoAtual = agora.getFullYear();
  const doaçõesDoMes = doacoes.filter(d => {
    const dt = new Date(d.dataDoacao + 'T00:00:00');
    return dt.getMonth() === mesAtual && dt.getFullYear() === anoAtual;
  });
  document.getElementById('totalMes').textContent = doaçõesDoMes.length;
}

// ---- TOAST DE FEEDBACK ----
function mostrarToast(mensagem, tipo = 'success') {
  const toastEl = document.getElementById('toastMsg');
  const toastText = document.getElementById('toastText');

  toastEl.className = 'toast align-items-center border-0 text-white';

  if (tipo === 'success') toastEl.classList.add('bg-success');
  else if (tipo === 'danger')  toastEl.classList.add('bg-danger');
  else if (tipo === 'warning') toastEl.classList.add('bg-warning');

  toastText.textContent = mensagem;

  const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
  toast.show();
}

// ---- HELPERS ----

function formatarData(dataISO) {
  if (!dataISO) return '-';
  const [ano, mes, dia] = dataISO.split('-');
  return `${dia}/${mes}/${ano}`;
}

function escaparHTML(str) {
  const div = document.createElement('div');
  div.appendChild(document.createTextNode(str));
  return div.innerHTML;
}

function classBadge(tipo) {
  const map = {
    'Alimento':               'alimento',
    'Roupa':                  'roupa',
    'Calçado':                'calcado',
    'Brinquedo':              'brinquedo',
    'Medicamento':            'medicamento',
    'Produto de Higiene':     'higiene',
    'Móvel / Eletrodoméstico':'movel',
    'Material Escolar':       'escolar',
    'Outro':                  'outro',
  };
  return map[tipo] || 'outro';
}
