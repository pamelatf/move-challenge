// Cria um card (issue) por suíte de testes automatizados, com a lista dos
// testes em checklist, e adiciona ao Project "Move Challenge: Testes".
//
// Os testes são lidos dos próprios arquivos, pelo padrão de nome
// "ID [regras] descrição" (o mesmo usado por gerar-mapa-automacao.js).
//
// Uso, na pasta do repositório:
//   node scripts/criar-issues-automacao.js
//
// Pode ser executado mais de uma vez: cards com o mesmo título não são
// criados de novo.

const { execFileSync } = require('child_process');
const fs = require('fs');
const os = require('os');
const path = require('path');

const REPO = 'pamelatf/move-challenge';
const DONO = 'pamelatf';
const TITULO_PROJECT = 'Move Challenge: Testes';
const RAIZ = path.resolve(__dirname, '..');
const URL_ARQUIVO = `https://github.com/${REPO}/blob/main`;
const PAGINA_MAPA = `https://github.com/${REPO}/wiki/11-Mapa-da-automa%C3%A7%C3%A3o`;

function gh(args, { silencioso = false } = {}) {
  try {
    return execFileSync('gh', args, { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] });
  } catch (e) {
    if (!silencioso) console.error(`  Erro ao executar gh ${args.slice(0, 2).join(' ')}: ${(e.stderr || e.message).trim()}`);
    return null;
  }
}

// Suítes: arquivo, título do card e camada
const SUITES = [
  { arquivos: ['test/domain/datas_test.dart'], titulo: 'UNI · Datas', camada: 'Unidade' },
  { arquivos: ['test/domain/pontuacao_test.dart'], titulo: 'UNI · Pontuação', camada: 'Unidade' },
  { arquivos: ['test/domain/ranking_test.dart'], titulo: 'UNI · Ranking', camada: 'Unidade' },
  { arquivos: ['test/domain/codigo_e_validacoes_test.dart'], titulo: 'UNI · Código e validações', camada: 'Unidade' },
  { arquivos: ['test/widget/activity_calendar_test.dart'], titulo: 'WID · Calendário de atividades', camada: 'Widget' },
  { arquivos: ['test/widget/marcacao_sheet_test.dart'], titulo: 'WID · Folha de marcação', camada: 'Widget' },
  { arquivos: ['test/widget/login_screen_test.dart'], titulo: 'WID · Login', camada: 'Widget' },
  { arquivos: ['test/widget/ranking_lane_test.dart', 'test/widget_test.dart'], titulo: 'WID · Ranking e boas-vindas', camada: 'Widget' },
  { arquivos: ['firestore-tests/test/regras.test.js'], titulo: 'REG · Regras de segurança do Firestore', camada: 'Regras do banco' },
  { pasta: '.maestro', titulo: 'E2E · Fluxos de ponta a ponta (Maestro)', camada: 'Ponta a ponta',
    falhando: ['E2E-01', 'E2E-02', 'E2E-04'],
    observacao: 'Os fluxos E2E-01, E2E-02 e E2E-04 falham hoje por causa do DEF-001 (#16), reproduzido de forma consistente no CI. Eles funcionam como teste de regressão do defeito e devem ficar verdes após a correção.' },
];

const PADRAO_CODIGO = /(?:test|testWidgets|it)\(\s*['"]((?:UNI|WID|REG)-\d+) \[([^\]]+)\] ([^'"]+)['"]/g;
const PADRAO_FLUXO = /^#\s*(E2E-\d+) \[([^\]]+)\] (.+)$/m;

function testesDa(suite) {
  const testes = [];
  if (suite.pasta) {
    const pasta = path.join(RAIZ, suite.pasta);
    for (const nome of fs.readdirSync(pasta).filter((n) => n.endsWith('.yaml')).sort()) {
      const m = fs.readFileSync(path.join(pasta, nome), 'utf8').match(PADRAO_FLUXO);
      if (m) testes.push({ id: m[1], regras: m[2], descricao: m[3].trim(), arquivo: `${suite.pasta}/${nome}` });
    }
    return testes;
  }
  for (const arquivo of suite.arquivos) {
    const texto = fs.readFileSync(path.join(RAIZ, arquivo), 'utf8');
    for (const m of texto.matchAll(PADRAO_CODIGO)) {
      testes.push({ id: m[1], regras: m[2], descricao: m[3].trim(), arquivo });
    }
  }
  return testes;
}

function corpoDa(suite, testes) {
  const arquivos = [...new Set(testes.map((t) => t.arquivo))];
  return [
    '## Suíte automatizada', '',
    '| Campo | Valor |', '|---|---|',
    `| Camada | ${suite.camada} |`,
    `| Testes | ${testes.length} |`,
    `| Arquivo | ${arquivos.map((a) => `[\`${a}\`](${URL_ARQUIVO}/${encodeURI(a)})`).join('<br>')} |`,
    '| Execução | A cada push, no GitHub Actions |', '',
    ...(suite.observacao ? ['> ' + suite.observacao, ''] : []),
    '## Testes', '',
    ...testes.map((t) => `- [${(suite.falhando || []).includes(t.id) ? ' ' : 'x'}] **${t.id}** [${t.regras}] ${t.descricao}`), '',
    'Itens marcados estão passando no CI; itens desmarcados estão falhando.', '',
    `Mapa completo da automação: [11 · Mapa da automação](${PAGINA_MAPA})`,
  ].join('\n');
}

const cards = SUITES.map((s) => {
  const testes = testesDa(s);
  return { titulo: s.titulo, etiquetas: ['tipo: automação'], corpo: corpoDa(s, testes), total: testes.length };
});

cards.push({
  titulo: 'AUT-PEND-01 · Fluxo de ponta a ponta para sair do desafio (RN10)',
  etiquetas: ['tipo: automação', 'prioridade: média'],
  corpo: [
    '## Lacuna de automação', '',
    'O mapa da automação mostra que a **RN10** (ao sair do desafio, os dias da pessoa são apagados e ela deixa o ranking) não tem nenhum teste automatizado. Hoje, ela depende do CT-12 e da sessão S08.', '',
    '## Proposta', '',
    'Criar o fluxo `E2E-05 [RN10]` no Maestro:', '',
    '- [ ] Criar conta e desafio, marcar o dia de hoje',
    '- [ ] Sair do desafio pelo Perfil e confirmar',
    '- [ ] Verificar que a tela "Entre no desafio" é exibida',
    '- [ ] Entrar de novo com o mesmo código e verificar que os pontos do mês estão zerados', '',
    'Complemento sugerido nas regras do banco: um teste `REG` confirmando que a pessoa consegue apagar a própria participação e não consegue apagar a de outra.', '',
    '**Dependência:** o fluxo passa pela abertura do desafio e, por isso, só deve ser criado após a correção do DEF-001 (#16).',
  ].join('\n'),
});

function numeroDoProject() {
  const saida = gh(['project', 'list', '--owner', DONO, '--format', 'json'], { silencioso: true });
  if (!saida) return null;
  const encontrados = JSON.parse(saida).projects.filter((p) => p.title === TITULO_PROJECT && !p.closed);
  if (encontrados.length > 1) console.log(`Há ${encontrados.length} Projects com o nome "${TITULO_PROJECT}". Usando o mais recente.`);
  const escolhido = encontrados.sort((a, b) => b.number - a.number)[0];
  return escolhido ? String(escolhido.number) : null;
}

function main() {
  if (!gh(['--version'], { silencioso: true })) {
    console.error('GitHub CLI não encontrada. Instale com: winget install GitHub.cli');
    process.exit(1);
  }
  gh(['label', 'create', 'tipo: automação', '--repo', REPO, '--color', '6F4FB8', '--description', 'Suíte de testes automatizados', '--force']);
  gh(['label', 'create', 'prioridade: média', '--repo', REPO, '--color', 'E0621A', '--force']);

  const existentes = new Set(
    JSON.parse(gh(['issue', 'list', '--repo', REPO, '--state', 'all', '--limit', '500', '--json', 'title']) || '[]').map((i) => i.title),
  );
  const projeto = numeroDoProject();
  if (!projeto) console.log(`Project "${TITULO_PROJECT}" não encontrado. Os cards serão criados, mas não adicionados.`);

  const temporario = path.join(os.tmpdir(), 'move-challenge-automacao.md');
  let criados = 0;
  for (const card of cards) {
    if (existentes.has(card.titulo)) { console.log(`Já existe: ${card.titulo}`); continue; }
    fs.writeFileSync(temporario, card.corpo, 'utf8');
    const args = ['issue', 'create', '--repo', REPO, '--title', card.titulo, '--body-file', temporario];
    for (const e of card.etiquetas) args.push('--label', e);
    const url = gh(args);
    if (!url) continue;
    criados++;
    console.log(`Criado: ${card.titulo}${card.total !== undefined ? ` (${card.total} testes)` : ''}`);
    if (projeto) gh(['project', 'item-add', projeto, '--owner', DONO, '--url', url.trim()]);
  }
  fs.rmSync(temporario, { force: true });
  console.log(`\nConcluído: ${criados} card(s) criado(s) de ${cards.length}.`);
}

main();
